module clkdiv
(
    input clk,
    output reg nclk //new clock
);

    parameter bits = 9, cycle = 500;//default=1us

    reg [bits-1:0] cnt;

    always @(posedge clk)
        if (cnt < cycle/2-1) begin
            nclk <= 1;
            cnt <= cnt + 1;
		end
        else if (cnt < cycle-1) begin
            nclk <= 0;
            cnt <= cnt + 1;
		end
        else begin
            nclk <= 1;
            cnt <= 0;
		end

endmodule