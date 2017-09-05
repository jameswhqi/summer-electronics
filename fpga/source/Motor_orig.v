// motor control
module Motor (
    // clock
    input clkus,
    // motor speed from Trackuturn
    input [1:0] speed,
    // IN pin of the 2 motor driver chips
    output reg [1:0] motor_ctrl,
    // INH pin of the 2 motor driver chips
    output reg [1:0] motor_en
);
    
    // motor speed
    parameter   MOTOR_STOP  = 2'b00,
                MOTOR_FOR   = 2'b01,
                MOTOR_BACK  = 2'b10,
                FAST_FORWARD= 2'b11;

    // period
    parameter   PERIOD  = 2273; // 440Hz

    // pulse width of different speed
    parameter   NORMAL  = 100,
                FAST    = 100;

    // counter
    reg [11:0] cnt;

    // indicates that motor_ctrl has switched from high to low
    reg switched;

    always @(posedge clkus) begin
        if (cnt == PERIOD - 1) begin
            cnt <= 0;
            switched <= 0;
        end
        else
            cnt <= cnt + 1;
        case (speed)
            MOTOR_STOP: begin
                motor_ctrl <= 2'b00;
                motor_en <= 2'b00;
            end
            MOTOR_FOR: begin
                if (cnt < NORMAL && !switched)
                    motor_ctrl <= 2'b10;
                else
                    motor_ctrl <= 2'b00;
                motor_en <= 2'b11;
                if (cnt == NORMAL)
                    switched <= 1;
            end
            MOTOR_BACK: begin
                if (cnt < NORMAL && !switched)
                    motor_ctrl <= 2'b01;
                else
                    motor_ctrl <= 2'b00;
                motor_en <= 2'b11;
                if (cnt == NORMAL)
                    switched <= 1;
            end
            FAST_FORWARD: begin
                if (cnt < FAST && !switched)
                    motor_ctrl <= 2'b10;
                else
                    motor_ctrl <= 2'b00;
                motor_en <= 2'b11;
                if (cnt == FAST)
                    switched <= 1;
            end
        endcase
    end

endmodule