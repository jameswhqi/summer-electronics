// servo control
module Servo (
    // global reset
    input rst,
    // clock
    input clkus,
    // front wheel direction
    input [2:0] direction,
    // servo PWM signal
    output reg pwm
);
    
    // front wheel direction
    parameter   STRAIGHT    = 3'b000,
                LEFT_SMALL  = 3'b001,
                LEFT_BIG    = 3'b011,
                RIGHT_SMALL = 3'b101,
                RIGHT_BIG   = 3'b111;

    // pulse width of each direction
    parameter   W_STRAIGHT      = 1500, // 1.5ms

    // 5ms period counter
    reg [12:0] cnt;

    

endmodule