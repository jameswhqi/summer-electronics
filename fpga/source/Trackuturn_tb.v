`timescale 1us/10ns
module Trackuturn_tb;
    reg rst, clk;
    reg en_tracking, en_uturn;
    reg [3:0] ir;
    wire [2:0] front_wheel;
    wire [1:0] motor;
    wire end_of_track, uturn_finished;
    
    Trackuturn trackuturn (.rst(rst), .clk(clk), .en_tracking(en_tracking), .en_uturn(en_uturn), .ir(ir),
               .front_wheel(front_wheel), .motor(motor), .end_of_track(end_of_track),
               .uturn_finished(uturn_finished));
    
    parameter Tburst = 2000, Ton = 1, Toff = 1;

    parameter WHITE = 1'b0, BLACK = 1'b1;
    
    initial begin
        repeat (Tburst) begin
            #Ton clk = 1;
            #Toff clk = 0;
        end
    end
    
    initial begin
        rst = 1;
        #5 rst = 0;
        #5 rst = 1;
    end
    
    initial begin
        // initial input
        en_tracking = 0;
        en_uturn = 0;
        ir = {WHITE, WHITE, WHITE, WHITE};
        // track
        #20 en_tracking = 1;
        #20 ir = {BLACK, WHITE, WHITE, WHITE};
        #20 ir = {WHITE, WHITE, WHITE, WHITE};

        #20 ir = {WHITE, WHITE, WHITE, BLACK};
        #20 ir = {WHITE, WHITE, WHITE, WHITE};

        #20 ir = {BLACK, WHITE, WHITE, WHITE};
        #20 ir = {BLACK, BLACK, WHITE, WHITE};
        #20 ir = {BLACK, WHITE, WHITE, WHITE};
        #20 ir = {WHITE, WHITE, WHITE, WHITE};

        #20 ir = {WHITE, WHITE, WHITE, BLACK};
        #20 ir = {WHITE, WHITE, BLACK, BLACK};
        #20 ir = {WHITE, WHITE, WHITE, BLACK};
        #20 ir = {WHITE, WHITE, WHITE, WHITE};

        #20 ir = {WHITE, BLACK, BLACK, WHITE};
        #20 ir = {BLACK, BLACK, BLACK, BLACK};

        #10 en_tracking = 0;
        // u-turn with forward cross ending
        #10 en_uturn = 1;
        // initial
        #20 ir = {WHITE, WHITE, WHITE, WHITE};
        #20 ir = {BLACK, BLACK, WHITE, WHITE};
        #20 ir = {BLACK, WHITE, WHITE, WHITE};
        // forward
        #40 ir = {BLACK, BLACK, WHITE, WHITE};
        #20 ir = {BLACK, BLACK, BLACK, WHITE};
        // backward
        #40 ir = {BLACK, BLACK, WHITE, WHITE};
        #20 ir = {WHITE, WHITE, WHITE, WHITE};
        // forward (switch)
        #40 ir = {WHITE, WHITE, BLACK, BLACK};
        #20 ir = {WHITE, BLACK, BLACK, BLACK};
        // backward
        #40 ir = {WHITE, WHITE, BLACK, BLACK};
        #20 ir = {WHITE, WHITE, WHITE, BLACK};
        // forward (final)
        #40 ir = {WHITE, WHITE, BLACK, BLACK};
        #20 ir = {WHITE, WHITE, WHITE, BLACK};

        #10 en_uturn = 0;

        #10 ir = {BLACK, BLACK, BLACK, BLACK};
        // u-turn with forward non-cross ending
        #10 en_uturn = 1;
        // initial
        #20 ir = {WHITE, WHITE, WHITE, WHITE};
        #20 ir = {BLACK, BLACK, WHITE, WHITE};
        #20 ir = {BLACK, WHITE, WHITE, WHITE};
        // forward
        #40 ir = {BLACK, BLACK, WHITE, WHITE};
        #20 ir = {BLACK, BLACK, BLACK, WHITE};
        // backward
        #40 ir = {BLACK, BLACK, WHITE, WHITE};
        #20 ir = {WHITE, WHITE, WHITE, WHITE};
        // forward (switch)
        #40 ir = {WHITE, WHITE, BLACK, BLACK};
        #20 ir = {WHITE, BLACK, BLACK, BLACK};
        // backward
        #40 ir = {WHITE, WHITE, BLACK, BLACK};
        #20 ir = {WHITE, WHITE, WHITE, BLACK};
        // forward (final)
        #40 ir = {WHITE, WHITE, WHITE, BLACK};
        #20 ir = {WHITE, WHITE, WHITE, WHITE};

        #10 en_uturn = 0;

        // u-turn with backword ending
        #10 en_uturn = 1;
        // initial
        #20 ir = {WHITE, WHITE, WHITE, WHITE};
        #20 ir = {BLACK, BLACK, WHITE, WHITE};
        #20 ir = {BLACK, WHITE, WHITE, WHITE};
        // forward
        #40 ir = {BLACK, BLACK, WHITE, WHITE};
        #20 ir = {BLACK, BLACK, BLACK, BLACK};
        // backward (switch)
        #40 ir = {WHITE, WHITE, BLACK, BLACK};
        #20 ir = {WHITE, WHITE, WHITE, BLACK};
        // forward
        #40 ir = {WHITE, WHITE, BLACK, BLACK};
        #20 ir = {WHITE, BLACK, BLACK, BLACK};
        // backward (final)
        #40 ir = {WHITE, WHITE, BLACK, BLACK};
        #20 ir = {WHITE, BLACK, BLACK, BLACK};
        #40 ir = {WHITE, WHITE, BLACK, BLACK};
        #20 ir = {WHITE, WHITE, WHITE, BLACK};
        #20 ir = {WHITE, WHITE, WHITE, WHITE};

        #10 en_uturn = 0;
    end
    
endmodule