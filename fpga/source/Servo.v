// servo control
module Servo (
    // clock
    input clkus,
    // front wheel direction from Trackuturn
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
    parameter   W_STRAIGHT      = 1450, // 0 deg
                W_LEFT_SMALL    = 1750, // -27 deg
                W_LEFT_BIG      = 1950, // -45 deg
                W_RIGHT_SMALL   = 1150, // 27 deg
                W_RIGHT_BIG     = 950; // 54 deg

    // 5ms period counter
    reg [12:0] cnt;

    // stores the current pulse width
    reg [12:0] width;

    // indicates that pwm has switched from high to low
    reg switched;

    always @(posedge clkus) begin
        if (cnt < 4999)
            cnt <= cnt + 1;
        else
            cnt <= 0;
        if (cnt == 4999)
            switched <= 0;
        else if (cnt == width)
            switched <= 1;
        case (direction)
            STRAIGHT:
                width <= W_STRAIGHT;
            LEFT_SMALL:
                width <= W_LEFT_SMALL;
            LEFT_BIG:
                width <= W_LEFT_BIG;
            RIGHT_SMALL:
                width <= W_RIGHT_SMALL;
            RIGHT_BIG:
                width <= W_RIGHT_BIG;
            default:
                width <= W_STRAIGHT;
        endcase
        if (cnt < width && !switched)
            pwm <= 1;
        else
            pwm <= 0;
    end

endmodule