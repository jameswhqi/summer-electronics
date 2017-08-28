module divide
(
    input clk,
    input [13:0] divider,
    input enable,
    output reg [8:0] freq,
    output reg enbcd
);
    
    reg [33:0] a;//10^6
    reg [13:0] b;

    reg [4:0] cnt;//20

    parameter STOP = 4'b0001, SHIFT = 4'b0010, MINUS = 4'b0100, END = 4'b1000;

    reg [3:0] cstate, nstate;

    always @(posedge clk)
        cstate <= nstate;

    always @(*)
        case (cstate)
            STOP:
                if (enable)
                    nstate = SHIFT;
                else
                    nstate = STOP;
            SHIFT:
                nstate = MINUS;
            MINUS:
                if (cnt == 0)
                    nstate = END;
                else 
                    nstate = SHIFT;
            END:
                nstate = STOP;
            default:
                nstate = STOP;
        endcase

    always @(posedge clk) //cnt, a, b
        case (nstate)
            STOP: begin
                cnt <= 20;
                a <= 1000000;
                b <= divider;
                enbcd <= 0;
            end
            SHIFT: begin
                a <= a << 1;
                cnt <= cnt - 1;
            end
            MINUS:
                if (a[33:20] >= b) begin
                    a[33:20] <= a[33:20] - b;
                    a[0] <= 1;
                end
            END: begin
                if (a[33:20] > b[13:1])
                    freq <= a[8:0] + 1;
                else
                    freq <= a[8:0];
                enbcd <= 1;
            end
        endcase
  
endmodule