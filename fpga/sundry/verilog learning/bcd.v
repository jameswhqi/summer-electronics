module bcd
(
    input clk,
    input [8:0] freq,
    input enable,
    output reg [11:0] digs
);

    reg [20:0] a;//12+9

    reg [3:0] cnt;//9

    parameter STOP = 4'b0001, SHIFT = 4'b0010, ADD = 4'b0100, END = 4'b1000;

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
                if (cnt == 0)
                    nstate = END;
                else
                    nstate = ADD;
            ADD:
                nstate = SHIFT;
            END:
                nstate = STOP;
            default:
                nstate = STOP;
        endcase

    always @(posedge clk) //cnt, a, b
        case (nstate)
            STOP: begin
                cnt <= 9;
                a <= freq;
            end
            SHIFT: begin
                a <= a << 1;
                cnt <= cnt - 1;
            end
            ADD: begin
                if (a[20:17] >= 5)
                    a[20:17] <= a[20:17] + 3;
                if (a[16:13] >= 5)
                    a[16:13] <= a[16:13] + 3;
                if (a[12:9] >= 5)
                    a[12:9] <= a[12:9] + 3;
            end
            END:
                digs <= a[20:9];
        endcase

endmodule