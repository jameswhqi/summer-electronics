// tracking and u-turn logic
module Trackuturn (
    // global reset
    input rst,
    // clock
    input clk,
    // binary signals of 4 infrared sensors
    input [3:0] ir,
    // enable signal from Core
    input en_tracking,
    input en_uturn,
    // front wheel direction to Servo
    // 000 straight  001 left small  011 left big  101 right small  111 right big
    output reg [2:0] front_wheel,
    // motor speed to Motor
    // 00 stop  01 forward  10 backward  11 fast forward
    output reg [1:0] motor,
    // end of track to Core
    output reg end_of_track,
    // u-turn finished to Core
    output reg uturn_finished,

    output reg [5:0] cstate,
    output reg crossed
);

    // fsm states
    parameter   STOP        = 6'b000001,
                TRACK       = 6'b000010, // tracking
                INITIAL     = 6'b000100, // initial backward movement of a u-turn process
                FORWARD     = 6'b001000, // going forward during u-turn
                BACKWARD    = 6'b010000, // going backward during u-turn
                FINAL       = 6'b100000; // final straight driving in case of ending after BACKWARD

    // current state, next state
    reg [5:0] nstate;

    // indicate whether ir[2] has touched black after touching white
    reg [1:0] initial_touch;

    // indicates that ir[2:1] has crossed the black-white border
    // reg crossed;

    // indicates that ir[0] has touched black
    reg right_black;

    // interpretation of signal from infrared sensors
    parameter WHITE = 1'b0, BLACK = 1'b1;

    // front wheel direction
    parameter   STRAIGHT    = 3'b000,
                LEFT_SMALL  = 3'b001,
                LEFT_BIG    = 3'b011,
                RIGHT_SMALL = 3'b101,
                RIGHT_BIG   = 3'b111;

    // motor speed
    parameter   MOTOR_STOP  = 2'b00,
                MOTOR_FOR   = 2'b01,
                MOTOR_BACK  = 2'b10,
                FAST_FORWARD= 2'b11;

    // delay before turning front wheels and before driving motor
    parameter   TURN_DELAY  = 25000000, // 0.5s
                DRIVE_DELAY = 40000000; // + 0.3s
    
    reg [25:0] delay;
    // for testing
    // parameter   TURN_DELAY  = 5,
    //             DRIVE_DELAY = 8;
    // reg [3:0] delay;
    reg delayed;

    // change state
    always @(posedge clk or negedge rst)
        if (!rst)
            cstate <= STOP;
        else
            cstate <= nstate;

    // state changing rules
    always @(*)
        case (cstate)
            STOP:
                if (en_tracking)
                    nstate = TRACK;
                else if (en_uturn && !uturn_finished)
                    nstate = INITIAL;
                else
                    nstate = STOP;
            TRACK:
                if (!en_tracking)
                    nstate = STOP;
                else
                    nstate = TRACK;
            INITIAL:
                if (initial_touch == 2)
                    nstate = FORWARD;
                else
                    nstate = INITIAL;
            FORWARD:
                if (ir[2] == BLACK && ir[1] == BLACK)
                    nstate = BACKWARD;
                else if (crossed && ir[2:1] == {WHITE, WHITE} || right_black && ir[2:0] == {WHITE, WHITE, WHITE})
                    nstate = STOP;
                else
                    nstate = FORWARD;
            BACKWARD:
                if (ir[2] == WHITE && ir[1] == WHITE)
                    nstate = FORWARD;
                else if (crossed && ir[2] == BLACK && ir[1] == BLACK)
                    nstate = FINAL;
                else
                    nstate = BACKWARD;
            FINAL:
                if (ir[0] == WHITE)
                    nstate = STOP;
                else
                    nstate = FINAL;
            default:
                nstate = STOP;
        endcase

    // front_wheel, motor, end_of_track, uturn_finished, initial_touch,
    // crossed, right_black, delay, delayed
    always @(posedge clk or negedge rst)
        if (!rst) begin
            front_wheel <= STRAIGHT;
            motor <= MOTOR_STOP;
            end_of_track <= 0;
            uturn_finished <= 0;
            initial_touch <= 0;
            crossed <= 0;
            right_black <= 0;
            delay <= 0;
            delayed <= 0;
        end
        else
            case (nstate)
                STOP: begin
                    front_wheel <= STRAIGHT;
                    motor <= MOTOR_STOP;
                    end_of_track <= 0;
                    if (cstate == FORWARD || cstate == FINAL)
                        uturn_finished <= 1;
                    else if (!en_uturn)
                        uturn_finished <= 0;
                    initial_touch <= 0;
                    crossed <= 0;
                    right_black <= 0;
                    delay <= 0;
                    delayed <= 0;
                end
                TRACK: begin
                    case (ir)
                        {BLACK, WHITE, WHITE, WHITE}:
                            front_wheel <= RIGHT_SMALL;
                        {BLACK, BLACK, WHITE, WHITE}:
                            front_wheel <= RIGHT_BIG;
                        {WHITE, WHITE, WHITE, BLACK}:
                            front_wheel <= LEFT_SMALL;
                        {WHITE, WHITE, BLACK, BLACK}:
                            front_wheel <= LEFT_BIG;
                        default:
                            front_wheel <= STRAIGHT;
                    endcase
                    if (end_of_track)
                        motor <= MOTOR_STOP;
                    else if (ir == {WHITE, WHITE, WHITE, WHITE})
                        motor <= FAST_FORWARD;
                    else
                        motor <= MOTOR_FOR;
                    if (ir == {BLACK, BLACK, BLACK, BLACK})
                        end_of_track <= 1;
                    uturn_finished <= 0;
                end
                INITIAL: begin
                    front_wheel <= RIGHT_BIG;
                    motor <= MOTOR_BACK;
                    if (initial_touch == 0 && ir[2] == WHITE)
                        initial_touch <= 1;
                    else if (initial_touch == 1 && ir[2] == BLACK)
                        initial_touch <= 2;
                end
                FORWARD: begin
                    if (delay >= TURN_DELAY)
                        front_wheel <= LEFT_BIG;
                    if (delay >= DRIVE_DELAY)
                        motor <= MOTOR_FOR;
                    else if (!delayed)
                        motor <= MOTOR_STOP;
                    if (cstate == BACKWARD) begin
                        crossed <= 0;
                        right_black <= 0;
                    end
                    if (ir[2:1] == {WHITE, BLACK})
                        crossed <= 1;
                    if (ir[0] == BLACK)
                        right_black <= 1;
                    if (delayed)
                        delay <= 0;
                    else
                        delay <= delay + 1;
                    if (cstate == BACKWARD)
                        delayed <= 0;
                    else if (delay >= DRIVE_DELAY)
                        delayed <= 1;
                end
                BACKWARD: begin
                    if (delay >= TURN_DELAY)
                        front_wheel <= RIGHT_BIG;
                    if (delay >= DRIVE_DELAY)
                        motor <= MOTOR_BACK;
                    else if (!delayed)
                        motor <= MOTOR_STOP;
                    if (cstate == FORWARD)
                        crossed <= 0;
                    if (ir[2:1] == {WHITE, BLACK})
                        crossed <= 1;
                    if (delayed)
                        delay <= 0;
                    else
                        delay <= delay + 1;
                    if (cstate == FORWARD)
                        delayed <= 0;
                    else if (delay >= DRIVE_DELAY)
                        delayed <= 1;
                end
                FINAL: begin
                    if (delay >= TURN_DELAY || delayed)
                        if (ir[1] == BLACK)
                            front_wheel <= RIGHT_SMALL;
                        else if (ir[0] == BLACK)
                            front_wheel <= STRAIGHT;
                    if (delay >= DRIVE_DELAY)
                        motor <= MOTOR_FOR;
                    else if (!delayed)
                        motor <= MOTOR_STOP;
                    if (delayed)
                        delay <= 0;
                    else
                        delay <= delay + 1;
                    if (cstate == BACKWARD)
                        delayed <= 0;
                    else if (delay >= DRIVE_DELAY)
                        delayed <= 1;
                end
            endcase
endmodule