// buzzer control
module Buzzer (
    // clock
    input clkms,
    // enable signal from Core
    input enable,
    // buzz_finished signal to Core
    output reg finished,
    // output to buzzer
    output reg buzz
);

    // number of clocks in a period
    parameter CLKS = 200; // 200ms
    reg [7:0] clkcnt;

    // total number of periods
    parameter PERIODS = 6;
    reg [2:0] periodcnt;

    // finished, buzz, clkcnt, periodcnt
    always @(posedge clkms)
        if (enable)
            if (clkcnt == 0 && !finished)
                if (periodcnt == 0) begin
                    periodcnt <= PERIODS;
                    buzz <= 1;
                    clkcnt <= CLKS;
                end
                else if (periodcnt == 1) begin
                    periodcnt <= 0;
                    buzz <= 0;
                    finished <= 1;
                end
                else begin
                    periodcnt <= periodcnt - 1;
                    buzz <= !buzz;
                    clkcnt <= CLKS;
                end
            else if (clkcnt > 0 && !finished)
                clkcnt = clkcnt - 1;
            else begin
                clkcnt <= 0;
                buzz <= 0;
            end
        else begin
            finished <= 0;
            buzz <= 0;
            clkcnt <= 0;
            periodcnt <= 0;
        end

endmodule