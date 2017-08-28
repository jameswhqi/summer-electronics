module count
(
    input clk, clk1,//20ns, 10us
    input sig,
    output reg endiv,
    output reg [13:0] cntout
);
    
    reg cnted;
    reg [3:0] cntslow;
    reg [13:0] cntfast;

    reg sent;

    parameter STOP = 2'b01, START = 2'b10;

    reg [1:0] cstate, nstate;

    always @(posedge clk1)
        cstate <= nstate;

    always @(*)
        case (cstate)
            STOP:
                if (!cnted && sig)
                    nstate = START;
                else
                    nstate = STOP;
            START:
                if (cntslow == 0)
                    nstate = STOP;
                else
                    nstate = START;
            default:
                nstate = STOP;
        endcase

    always @(posedge clk1) //cnted, cntslow, cntfast
        case (nstate)
            STOP: begin
                if (cnted && !sig)
                    cnted <= 0;
                cnted <= 0;
                cntslow <= 11;
                if (cntfast != 0)
                    cntout <= cntfast;
                cntfast <= 0;
            end
            START: begin
                if (!cnted && sig) begin
                    cntslow <= cntslow - 1;
                    cnted <= 1;
                end
                if (!sig)
                    cnted <= 0;
                cntfast <= cntfast + 1;
            end
        endcase

    always @(posedge clk) //sent
        if (cntfast != 0)
            sent <= 0;
        else
            sent <= 1;

    always @(posedge clk) //endiv
        if (cntfast == 0 && !sent)
            endiv <= 1;
        else
            endiv <= 0;


endmodule