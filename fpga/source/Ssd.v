// SSD control
module Ssd (
    // clocks
    input clkus, clkms,
    // state code from Core
    input [3:0] state,
    // bit and seg of SSD
    output reg [3:0] bit,
    output reg [6:0] seg
);

    // ROM variable that stores SSD data
    reg [6:0] rom [0:139];
    
    // initialize the ROM
    initial
        $readmemb("ssd_data.txt", rom);

    // internal register that stores display data of each of the 4 SSDs
    reg [6:0] segs [3:0];

    // internal register that stores current state
    reg [3:0] state_intl;

    // start address of current state
    reg [6:0] start_addr;

    // number of ministates of current state
    reg [6:0] num_ministates;

    // current ministate
    reg [4:0] ministate;

    // current phase of a state reading process
    reg phase;

    // counter for ministate changing
    parameter PERIOD = 250000; // 250ms
    reg [17:0] minicnt;

    // segs, state_intl, start_addr, num_ministates, ministate, phase, minicnt
    always @(posedge clkus) begin
        if (state != state_intl || num_ministates == 0 || state >= 10) begin
            state_intl <= state;
            if (state < 10)
                start_addr <= rom[state];
            else
                start_addr <= rom[0];
            phase <= 1;
        end
        if (phase == 1) begin
            num_ministates <= rom[start_addr];
            ministate <= 0;
            minicnt <= 0;
            phase <= 0;
        end
        if (minicnt == 0) begin
            if (ministate == num_ministates - 1)
                ministate <= 0;
            else
                ministate <= ministate + 1;
            segs[3] <= rom[start_addr + (ministate << 2) + 1];
            segs[2] <= rom[start_addr + (ministate << 2) + 2];
            segs[1] <= rom[start_addr + (ministate << 2) + 3];
            segs[0] <= rom[start_addr + (ministate << 2) + 4];
        end
        if (minicnt == PERIOD - 1)
            minicnt <= 0;
        else
            minicnt <= minicnt + 1;
    end

    // bit, seg
    always @(posedge clkms) begin
        case (bit)
            4'b1000: begin
                bit <= 4'b0100;
                seg <= segs[2];
            end
            4'b0100: begin
                bit <= 4'b0010;
                seg <= segs[1];
            end
            4'b0010: begin
                bit <= 4'b0001;
                seg <= segs[0];
            end
            4'b0001: begin
                bit <= 4'b1000;
                seg <= segs[3];
            end
            default: begin
                bit <= 4'b1000;
                seg <= segs[3];
            end
        endcase
    end
endmodule