// Core module
module Core (
    // global reset
    input rst,
    // crystal clock of 50MHz
    input clk,
    // binary signal from hall sensor
    input hall,
    // encoded color type from Color module
    input [1:0] object_color,
    input [1:0] station_color,
    // feedback from Tracking module
    // end of track
    input end_of_track,
    // feedback from Uturn module
    // u-turn finished
    input uturn_finished,
    // feedback from Buzzer module
    // error buzzing finished
    input buzz_finished,
    // enable Tracking module
    output reg en_tracking,
    // enable Uturn module
    output reg en_uturn,
    // status code to ssd control
    // 0 ready          1/2/3 sending red/green/blue    4/5/6 red/green/blue arrived
    // 7 end of track   8 u-turning                     9 returning
    output reg [3:0] ssd_code,
    // enable Buzzer module
    output reg en_buzz
);

    // fsm states
    parameter   READY   = 7'b0000001,
                NOCOLOR = 7'b0000010,
                SEND    = 7'b0000100,
                MATCH   = 7'b0001000,
                UTURN   = 7'b0010000,
                RETURN  = 7'b0100000,
                EOT     = 7'b1000000;

    // current state, next state
    reg [6:0] cstate, nstate;

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
    always @(cstate)
        case (cstate)
            READY:
                if (hall) begin
                    if (in_color == 0)
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
                if (hall)
                    nstate = UTURN;
                else
                    nstate = MATCH;
            UTURN:
                if (uturn_finished)
                    if (returning)
                        nstate = READY;
                    else
                        nstate = RETURN;
                else
                    nstate = UTURN;
            RETURN:
                if (end_of_track)
                    nstate = UTURN;
                else
                    nstate = RETURN;
            EOT:
                if (buzz_finished)
                    nstate = UTURN;
                else
                    nstate = EOT;
            default:
                nstate = READY;
        endcase

    // en_tracking, en_uturn, ssd_code, en_buzz, object_color_detected, returning
    always @(posedge clk or negedge rst)
        if (rst) begin
            en_tracking <= 0;
            en_uturn <= 0;
            ssd_code <= 0;
            en_buzz <= 0;
            object_color_detected <= 0;
            returning <= 0;
        end
        else
            case (nstate)
                READY: begin
                    en_uturn <= 0;
                    ssd_code <= 0;
                    en_buzz <= 0;
                end
                NOCOLOR:
                    en_buzz <= 1;
                SEND: begin
                    en_tracking <= 1;
                    case (object_color_detected)
                        1: ssd_code <= 1;
                        2: ssd_code <= 2;
                        3: ssd_code <= 3;
                    endcase
                    object_color_detected <= object_color;
                end
                MATCH: begin
                    case (object_color_detected)
                        1: ssd_code <= 4;
                        2: ssd_code <= 5;
                        3: ssd_code <= 6;
                    endcase
                    en_tracking <= 0;
                    en_buzz <= 1;
                end
                UTURN: begin
                    ssd_code <= 8;
                    en_uturn <= 1;
                    en_buzz <= 0;
                end
                RETURN: begin
                    en_tracking <= 1;
                    en_uturn <= 0;
                    ssd_code <= 9;
                    object_color_detected <= 0;
                    returning <= 1;
                end
                EOT:
                    ssd_code <= 7;
                    en_tracking <= 0;
                    en_buzz <= 1;
                end

endmodule