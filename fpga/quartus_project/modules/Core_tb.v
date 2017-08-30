`timescale 1us/10ns
module Core_tb;
    reg rst, clk;
    reg hall, end_of_track, uturn_finished, buzz_finished;
    reg [1:0] object_color, station_color;
    wire en_tracking, en_uturn, en_buzz;
    wire [3:0] ssd_code;
    
    Core core (.rst(rst), .clk(clk), .hall(hall), .object_color(object_color), .station_color(station_color),
               .end_of_track(end_of_track), .uturn_finished(uturn_finished), .buzz_finished(buzz_finished),
               .en_tracking(en_tracking), .en_uturn(en_uturn), .ssd_code(ssd_code), .en_buzz(en_buzz));
    
    parameter Tburst = 400, Ton = 1, Toff = 1;
    
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
        hall = 0;
        end_of_track = 0;
        uturn_finished = 0;
        buzz_finished = 0;
        object_color = 0;
        station_color = 0;
        // no color, require start
        #20 hall = 1;
        #10 hall = 0;
        #10 buzz_finished = 1;
        #4 buzz_finished = 0;
        // red, require start
        #10 object_color = 1;
        #10 hall = 1;
        #10 hall = 0;
        // encounter blue station
        #30 station_color = 3;
        #4 station_color = 0;
        // encounter red station
        #30 station_color = 1;
        #4 station_color = 0;
        #10 buzz_finished = 1;
        #4 buzz_finished = 0;
        // require return
        #10 hall = 1;
        #10 hall = 0;
        #10 uturn_finished = 1;
        #4 uturn_finished = 0;
        #30 end_of_track = 1;
        #4 end_of_track = 0;
        #10 uturn_finished = 1;
        #4 uturn_finished = 0;
        // green, require start
        #10 object_color = 2;
        #10 hall = 1;
        #10 hall = 0;
        // reach end of track
        #30 end_of_track = 1;
        #4 end_of_track = 0;
        #10 buzz_finished = 1;
        #4 buzz_finished = 0;
        #10 uturn_finished = 1;
        #4 uturn_finished = 0;
        #30 end_of_track = 1;
        #4 end_of_track = 0;
        #10 uturn_finished = 1;
        #4 uturn_finished = 0;
    end
    
endmodule