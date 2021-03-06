// core logic
module Core (
    // global reset
    input rst,
    // crystal clock of 50MHz
    input clk,
    // binary signal from hall sensor
    input hall,
    // encoded color type from Color
    input [1:0] object_color,
    input [1:0] station_color,
    // feedbacks from Trackuturn
    // end of track
    input end_of_track,
    // u-turn finished
    input uturn_finished,

    input brake_finished, reverse_finished, fbrake_finished,
    // feedback from Buzzer
    // error buzzing finished
    input buzz_finished,
    // enable tracking in Trackuturn
    output reg en_tracking,
    // enable uturn in Trackuturn
    output reg en_uturn,

    output reg en_brake, en_reverse, en_fbrake,
    // display state code to Ssd
    // 0 ready          1/2/3 sending red/green/blue    4/5/6 red/green/blue arrived
    // 7 end of track   8 u-turning                     9 returning
    output reg [3:0] ssd_state,
    // enable Buzzer
    output reg en_buzz,

    output reg en_object, en_station

    //output reg [7:0] cstate
);

    // fsm states
    parameter   READY   = 9'b000000001,
                NOCOLOR = 9'b000000010,
                SEND    = 9'b000000100,
                MATCH   = 9'b000001000,
                UTURN   = 9'b000010000,
                RETURN  = 9'b000100000,
                EOT     = 9'b001000000,
                REVERSE = 9'b010000000,
                EOR     = 9'b100000000;

    // current state, next state
    reg [8:0] cstate, nstate;

    reg [1:0] object_color_detected;
    // determines what to do after a u-turn
    reg returning;

    // change state
    always @(posedge clk or negedge rst)
        if (!rst)
            cstate <= READY;
        else
            cstate <= nstate;

    // state changing rules
    always @(*)
        case (cstate)
            READY:
                if (!hall)
                    if (object_color == 0)
                        nstate = NOCOLOR;
                    else
                        nstate = SEND;
                else
                    nstate = READY;
            NOCOLOR:
                if (buzz_finished)
                    nstate = READY;
                else
                    nstate = NOCOLOR;
            SEND:
                if (station_color == object_color_detected)
                    nstate = MATCH;
                else if (end_of_track)
                    nstate = EOT;
                else
                    nstate = SEND;
            MATCH:
                if (!hall)
                    nstate = UTURN;
                else
                    nstate = MATCH;
            UTURN:
                if (uturn_finished)
                    if (returning)
                        nstate = REVERSE;
                    else
                        nstate = RETURN;
                else
                    nstate = UTURN;
            RETURN:
                if (end_of_track)
                    nstate = EOT;
                else
                    nstate = RETURN;
            EOT:
                if ((buzz_finished || returning) && brake_finished)
                    nstate = UTURN;
                else
                    nstate = EOT;
            REVERSE:
                if (reverse_finished)
                    nstate = EOR;
                else
                    nstate = REVERSE;
            EOR:
                if (fbrake_finished)
                    nstate = READY;
                else
                    nstate = EOR;
            default:
                nstate = READY;
        endcase

    // en_tracking, en_uturn, en_brake, en_reverse, ssd_state, en_buzz, en_object, en_station,
    // object_color_detected, returning
    always @(posedge clk or negedge rst)
        if (!rst) begin
            en_tracking <= 0;
            en_uturn <= 0;
            en_brake <= 0;
            en_reverse <= 0;
            en_fbrake <= 0;
            ssd_state <= 0;
            en_buzz <= 0;
            en_object <= 1;
            en_station <= 0;
            object_color_detected <= 0;
            returning <= 0;
        end
        else
            case (nstate)
                READY: begin
                    en_uturn <= 0;
                    en_brake <= 0;
                    en_reverse <= 0;
                    en_fbrake <= 0;
                    ssd_state <= 0;
                    en_buzz <= 0;
                    en_object <= 1;
                    en_station <= 0;
                    returning <= 0;
                end
                NOCOLOR:
                    en_buzz <= 1;
                SEND: begin
                    en_tracking <= 1;
                    case (object_color_detected)
                        1: ssd_state <= 1;
                        2: ssd_state <= 2;
                        3: ssd_state <= 3;
                    endcase
                    en_object <= 0;
                    en_station <= 1;
                    if (cstate == READY)
                        object_color_detected <= object_color;
                end
                MATCH: begin
                    case (object_color_detected)
                        1: ssd_state <= 4;
                        2: ssd_state <= 5;
                        3: ssd_state <= 6;
                    endcase
                    en_tracking <= 0;
                    en_brake <= 1;
                    en_buzz <= 1;
                    en_station <= 0;
                end
                UTURN: begin
                    en_tracking <= 0;
                    ssd_state <= 8;
                    en_uturn <= 1;
                    en_buzz <= 0;
                end
                RETURN: begin
                    en_tracking <= 1;
                    en_uturn <= 0;
                    ssd_state <= 9;
                    object_color_detected <= 0;
                    returning <= 1;
                end
                EOT: begin
                    ssd_state <= 7;
                    en_tracking <= 0;
                    en_brake <= 1;
                    if (!returning)
                        en_buzz <= 1;
                    en_station <= 0;
                end
                REVERSE: begin
                    en_reverse <= 1;
                    en_uturn <= 0;
                end
                EOR: begin
                    en_reverse <= 0;
                    en_fbrake <= 1;
                end
            endcase

endmodule