module display
(
    input clk2,//4ms
    input [11:0] digs,
    output reg [3:0] bit,
    output reg [6:0] seg
);

    parameter S3 = 4'b1000, S2 = 4'b0100, S1 = 4'b0010, S0 = 4'b0001;

    reg [3:0] cstate = S3, nstate = S3;
    reg [3:0] dig;

    always @(posedge clk2)
        cstate <= nstate;

    always @(*)
        case (cstate)
            S3:
                nstate = S2;
            S2:
                nstate = S1;
            S1:
                nstate = S0;
            S0:
                nstate = S3;
            default:
                nstate = S3;
        endcase

    always @(posedge clk2)
        case (nstate)
            S3: begin
                bit <= 4'b1000;
                dig <= 4'b1111;
            end
            S2: begin
                bit <= 4'b0100;
                dig <= digs[11:8];
            end
            S1: begin
                bit <= 4'b0010;
                dig <= digs[7:4];
            end
            S0: begin
                bit <= 4'b0001;
                dig <= digs[3:0];
            end
        endcase

    always @(*) begin
        seg[6] = ~(~dig[3]&~dig[2]&~dig[1]&dig[0]|dig[3]&dig[1]|dig[2]&~dig[0]);
        seg[5] = ~(dig[3]&dig[1]|dig[2]&dig[1]&~dig[0]|dig[2]&~dig[1]&dig[0]);
        seg[4] = ~(dig[3]&dig[2]|~dig[2]&dig[1]&~dig[0]);
        seg[3] = ~(dig[2]&dig[1]&dig[0]|dig[2]&~dig[1]&~dig[0]|~dig[2]&~dig[1]&dig[0]);
        seg[2] = ~(dig[2]&~dig[1]|dig[0]);
        seg[1] = ~(~dig[3]&~dig[2]&dig[0]|~dig[2]&dig[1]|dig[1]&dig[0]);
        seg[0] = ~(~dig[3]&~dig[2]&~dig[1]|dig[2]&dig[1]&dig[0]);
    end
endmodule