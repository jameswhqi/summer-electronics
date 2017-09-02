// color interpretation
module Color (
    // clock
    input clkus,
    // square wave from color sensors
    input object_wave,
    input station_wave,
    // color selection to color sensor modules {S2, S3}
    output reg [1:0] object_select,
    output reg [1:0] station_select,
    // encoded color type to Core
    output reg [1:0] object_color,
    output reg [1:0] station_color

    // input [1:0] out_select,
    // output reg [7:0] cnt_out
);

    // color selection code
    parameter   SELECT_R    = 2'b00,
                SELECT_G    = 2'b11,
                SELECT_B    = 2'b01;

    // counting time for each color
    parameter PERIOD = 2000; // 2ms

    // period counter
    reg [10:0] cnt;

    reg [9:0] obj_cnt_r, obj_cnt_g, obj_cnt_b; // max 256kHz
    reg [9:0] stn_cnt_r, stn_cnt_g, stn_cnt_b;

    // current mode
    parameter   CNT_R   = 2'b00,
                CNT_G   = 2'b01,
                CNT_B   = 2'b10,
                CALC    = 2'b11;
    reg [1:0] mode;

    // indicates that calculation is done
    reg calc_done;

    always @(posedge clkus) begin
        if (cnt == PERIOD - 1) begin
            cnt <= 0;
            mode <= mode + 1;
        end
        else
            cnt <= cnt + 1;
        case (mode)
            CNT_R: begin
                object_select <= SELECT_R;
                station_select <= SELECT_R;
                calc_done <= 0;
            end
            CNT_G: begin
                object_select <= SELECT_G;
                station_select <= SELECT_G;
            end
            CNT_B: begin
                object_select <= SELECT_B;
                station_select <= SELECT_B;
            end
            CALC:
                if (!calc_done) begin
                    if (obj_cnt_r >= 20 && obj_cnt_r < 40 && obj_cnt_r > obj_cnt_b && obj_cnt_r - obj_cnt_r[9:2] - obj_cnt_r[9:3] > obj_cnt_g && obj_cnt_b > obj_cnt_g
                        || obj_cnt_r >= 40 && obj_cnt_r - obj_cnt_r[9:2] > obj_cnt_b && obj_cnt_r - obj_cnt_r[9:1] > obj_cnt_g && obj_cnt_b > obj_cnt_g)
                        object_color <= 1;
                    else if (obj_cnt_g >= 16 && obj_cnt_g > obj_cnt_r && obj_cnt_g > obj_cnt_b)
                        object_color <= 2;
                    else if (obj_cnt_b >= 24 && obj_cnt_b < 48 && obj_cnt_b - obj_cnt_b[9:2] > obj_cnt_r && obj_cnt_b - obj_cnt_b[9:2] > obj_cnt_g
                             || obj_cnt_b >= 48 && obj_cnt_b - obj_cnt_b[9:2] - obj_cnt_b[9:3] > obj_cnt_r && obj_cnt_b - obj_cnt_b[9:2] - obj_cnt_b[9:3] > obj_cnt_g)
                        object_color <= 3;
                    else
                        object_color <= 0;

                    if (stn_cnt_r >= 20 && stn_cnt_r < 40 && stn_cnt_r > stn_cnt_b && stn_cnt_r - stn_cnt_r[9:2] - stn_cnt_r[9:3] > stn_cnt_g && stn_cnt_b > stn_cnt_g
                        || stn_cnt_r >= 40 && stn_cnt_r - stn_cnt_r[9:2] > stn_cnt_b && stn_cnt_r - stn_cnt_r[9:1] > stn_cnt_g && stn_cnt_b > stn_cnt_g)
                        station_color <= 1;
                    else if (stn_cnt_g >= 16 && stn_cnt_g > stn_cnt_r && stn_cnt_g > stn_cnt_b)
                        station_color <= 2;
                    else if (stn_cnt_b >= 24 && stn_cnt_b < 48 && stn_cnt_b - stn_cnt_b[9:2] > stn_cnt_r && stn_cnt_b - stn_cnt_b[9:2] > stn_cnt_g
                             || stn_cnt_b >= 48 && stn_cnt_b - stn_cnt_b[9:2] - stn_cnt_b[9:3] > stn_cnt_r && stn_cnt_b - stn_cnt_b[9:2] - stn_cnt_b[9:3] > stn_cnt_g)
                        station_color <= 3;
                    else
                        station_color <= 0;
                        
                    // case (out_select)
                    //     1:
                    //         cnt_out <= obj_cnt_r;
                    //     2:
                    //         cnt_out <= obj_cnt_g;
                    //     3:
                    //         cnt_out <= obj_cnt_b;
                    // endcase
                    calc_done <= 1;
                end
        endcase
    end

    always @(posedge object_wave)
        case (mode)
            CNT_R: begin
                obj_cnt_r <= obj_cnt_r + 1;
            end
            CNT_G: begin
                obj_cnt_g <= obj_cnt_g + 1;
            end
            CNT_B: begin
                obj_cnt_b <= obj_cnt_b + 1;
            end
            CALC:
                if (calc_done) begin
                    obj_cnt_r <= 0;
                    obj_cnt_g <= 0;
                    obj_cnt_b <= 0;
                end
        endcase

    always @(posedge station_wave)
        case (mode)
            CNT_R: begin
                stn_cnt_r <= stn_cnt_r + 1;
            end
            CNT_G: begin
                stn_cnt_g <= stn_cnt_g + 1;
            end
            CNT_B: begin
                stn_cnt_b <= stn_cnt_b + 1;
            end
            CALC:
                if (calc_done) begin
                    stn_cnt_r <= 0;
                    stn_cnt_g <= 0;
                    stn_cnt_b <= 0;
                end
        endcase

endmodule