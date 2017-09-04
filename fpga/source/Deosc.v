// infrared signal deoscillation
module Deosc (
    // clk
    input clkus,
    // input signal
    input in,
    // output signal
    output reg out
);
    
    // previous state
    reg prev;

    // wait counter
    parameter TIME = 1000; // 1ms
    reg [9:0] cnt;

    always @(posedge clkus) begin
        if (in != prev && cnt == 0)
            cnt <= TIME;
        if (in != prev && cnt > 0)
            cnt <= cnt - 1;
        if (in != prev && cnt == 1) begin
            out <= in;
            prev <= in;
        end
        if (in == prev)
            cnt <= 0;
    end

endmodule