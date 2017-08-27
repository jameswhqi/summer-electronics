// Top module
module Top
(
    // crystal clock of 50MHz
    input clk,
    // binary signals of 4 infrared sensors
    input [3:0] ir,
    // binary signal of hall sensor
    input hall,
    // square wave from color sensor
    input color
    // PWM signal to servomotor
    output servo
    // IN pin of the 2 motor driver chips
    output [1:0] motor_ctrl
    // INH pin of the 2 motor driver chips
    output [1:0] motor_en
    // seven-segment displays
    output [3:0] bit,
    output [6:0] seg,
    // buzzer
    output buzz
);

    wire clk1;//10us
    clkdiv #(9, 500) Clk1 (.clk(clk), .nclk(clk1));

    wire clk2;//4ms
    clkdiv #(9, 400) Clk2 (.clk(clk1), .nclk(clk2));

    wire clk3;//0.5s
    clkdiv #(7, 128) Clk3 (.clk(clk2), .nclk(clk3));

    wire endiv;
    wire [13:0] cnt;
    count Count (.clk(clk), .clk1(clk1), .sig(sig), .endiv(endiv), .cntout(cnt));

    wire [8:0] freq;
    wire enbcd;
    divide Divide (.clk(clk), .divider(cnt), .enable(endiv), .freq(freq), .enbcd(enbcd));

    wire [11:0] digs;
    reg [11:0] digs2;
    bcd Bcd (.clk(clk), .freq(freq), .enable(enbcd), .digs(digs));

    display Display (.clk2(clk2), .digs(digs2), .bit(bit), .seg(seg));

    always @(posedge clk3)
        digs2 <= digs;

endmodule