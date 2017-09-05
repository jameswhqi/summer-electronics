// tracking and u-turn logic
module Trackuturn (
    // global reset
    input rst,
    // clock
    input clkus,
    // binary signals of 4 infrared sensors
    input [3:0] ir,
    // enable signal from Core
    input en_tracking, en_uturn, en_brake, en_reverse,
    // front wheel direction to Servo
    // 000 straight  001 left small  011 left big  101 right small  111 right big
    output reg [1:0] front_wheel,
    // motor speed to Motor
    // 00 stop  01 forward  10 backward  11 brake
    output reg [1:0] motor,
    // end of track to Core
    output reg end_of_track,
    // u-turn finished to Core
    output reg uturn_finished,

    output reg brake_finished, reverse_finished
);

    // fsm states
    parameter   STOP        = 6'b000001,
                TRACK       = 6'b000010, // tracking
                BRAKE       = 6'b000100,
                FORWARD     = 6'b001000, // going forward during u-turn
                BACKWARD    = 6'b010000, // going backward during u-turn
                REVERSE     = 6'b100000;

    // current state, next state
    reg [5:0] cstate, nstate;

    // interpretation of signal from infrared sensors
    parameter WHITE = 1'b0, BLACK = 1'b1;

    // front wheel direction
    parameter   STRAIGHT    = 2'b00,
                LEFT        = 2'b01,
                RIGHT       = 2'b11;

    // motor speed
    parameter   MOTOR_STOP  = 2'b00,
                MOTOR_FOR   = 2'b01,
                MOTOR_BACK  = 2'b10,
                MOTOR_BRAKE = 2'b11;

    // delay before turning front wheels and before driving motor
    parameter   TURN_DELAY  = 500000, // 0.5s
                DRIVE_DELAY = 800000; // + 0.3s
    
    reg [19:0] delay;
    // for testing
    // parameter   TURN_DELAY  = 5,
    //             DRIVE_DELAY = 8;
    // reg [3:0] delay;
    reg delayed;

    parameter BRAKE_TIME = 1000000; // 1s
    reg [19:0] brake_cnt;

    reg double_white;

    // change state
    always @(posedge clkus or negedge rst)
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
                    nstate = FORWARD;
                else if (en_brake && !brake_finished)
                    nstate = BRAKE;
                else if (en_reverse && !reverse_finished)
                    nstate = REVERSE;
                else
                    nstate = STOP;
            TRACK:
                if (!en_tracking)
                    nstate = STOP;
                else
                    nstate = TRACK;
            BRAKE:
                if (brake_cnt == 1)
                    nstate = STOP;
                else
                    nstate = BRAKE;
            FORWARD:
                if (double_white && (ir[2] == BLACK || ir[1] == BLACK))
                    nstate = BACKWARD;
                else if (ir == {WHITE, WHITE, WHITE, WHITE})
                    nstate = STOP;
                else
                    nstate = FORWARD;
            BACKWARD:
                if (double_white && (ir[2] == BLACK || ir[1] == BLACK))
                    nstate = FORWARD;
                else if (ir == {WHITE, WHITE, WHITE, WHITE})
                    nstate = STOP;
                else
                    nstate = BACKWARD;
            REVERSE:
                if (ir[2:1] == {BLACK, BLACK})
                    nstate = STOP;
                else
                    nstate = REVERSE;
            default:
                nstate = STOP;
        endcase

    // front_wheel, motor, end_of_track, uturn_finished, brake_finished, reverse_finished,
    // brake_cnt, delay, delayed, double_white
    always @(posedge clkus or negedge rst)
        if (!rst) begin
            front_wheel <= STRAIGHT;
            motor <= MOTOR_STOP;
            end_of_track <= 0;
            uturn_finished <= 0;
            brake_finished <= 0;
            reverse_finished <= 0;
            delay <= 0;
            delayed <= 0;
            brake_cnt <= 0;
            double_white <= 0;
        end
        else
            case (nstate)
                STOP: begin
                    front_wheel <= STRAIGHT;
                    motor <= MOTOR_STOP;
                    end_of_track <= 0;
                    if (cstate == FORWARD || cstate == BACKWARD)
                        uturn_finished <= 1;
                    else if (!en_uturn)
                        uturn_finished <= 0;
                    if (cstate == BRAKE)
                        brake_finished <= 1;
                    else if (!en_brake)
                        brake_finished <= 0;
                    if (cstate == REVERSE)
                        reverse_finished <= 1;
                    else if (!en_reverse)
                        reverse_finished <= 0;
                    delay <= 0;
                    delayed <= 0;
                    brake_cnt <= 0;
                    double_white <= 0;
                end
                TRACK: begin
                    if (ir[3] == BLACK && ir[0] == WHITE)
                        front_wheel <= RIGHT;
                    else if (ir[3] == WHITE && ir[0] == BLACK)
                        front_wheel <= LEFT;
                    else
                        front_wheel <= STRAIGHT;
                    if (end_of_track)
                        motor <= MOTOR_STOP;
                    else
                        motor <= MOTOR_FOR;
                    if (ir == {BLACK, BLACK, BLACK, BLACK})
                        end_of_track <= 1;
                end
                BRAKE: begin
                    front_wheel <= STRAIGHT;
                    motor <= MOTOR_BRAKE;
                    if (brake_cnt == 0)
                        brake_cnt <= BRAKE_TIME;
                    else
                        brake_cnt <= brake_cnt - 1;
                end
                FORWARD: begin
                    if (delay >= TURN_DELAY)
                        front_wheel <= LEFT;
                    if (delay >= DRIVE_DELAY)
                        motor <= MOTOR_FOR;
                    else if (!delayed)
                        motor <= MOTOR_STOP;
                    if (cstate == BACKWARD)
                        double_white <= 0;
                    if (ir[2:1] == {WHITE, WHITE})
                        double_white <= 1;
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
                        front_wheel <= RIGHT;
                    if (delay >= DRIVE_DELAY)
                        motor <= MOTOR_BACK;
                    else if (!delayed)
                        motor <= MOTOR_STOP;
                    if (cstate == FORWARD)
                        double_white <= 0;
                    if (ir[2:1] == {WHITE, WHITE})
                        double_white <= 1;
                    if (delayed)
                        delay <= 0;
                    else
                        delay <= delay + 1;
                    if (cstate == FORWARD)
                        delayed <= 0;
                    else if (delay >= DRIVE_DELAY)
                        delayed <= 1;
                end
                REVERSE: begin
                    front_wheel <= STRAIGHT;
                    motor <= MOTOR_BACK;
                end
            endcase
endmodule