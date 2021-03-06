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
    parameter   STRAIGHT    = 2'b00,
                LEFT        = 2'b01,
                RIGHT       = 2'b11;

    // pulse width of each direction
    parameter   W_STRAIGHT  = 1450, // 0 deg
                W_LEFT      = 1950, // -45 deg
                W_RIGHT     = 950; // 54 deg

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
            LEFT:
                width <= W_LEFT;
            RIGHT:
                width <= W_RIGHT;
            default:
                width <= W_STRAIGHT;
        endcase
        if (cnt < width && !switched)
            pwm <= 1;
        else
            pwm <= 0;
    end

endmodule