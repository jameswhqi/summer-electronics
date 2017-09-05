// Top module
module Top (
    // global reset
    input rst,
    // crystal clock of 50MHz
    input clk,
    // binary signals of 4 infrared sensors
    input [3:0] ir_in,
    // binary signal of hall sensor
    input hall,
    // square wave from color sensors
    input object_wave,
    input station_wave,
    // color selection to color sensor modules
    output [1:0] object_select,
    output [1:0] station_select,
    // PWM signal to servomotor
    output servo_pwm,
    // IN pin of the 2 motor driver chips
    output [1:0] motor_ctrl,
    // INH pin of the 2 motor driver chips
    output [1:0] motor_en,
    // seven-segment displays
    output [3:0] bit,
    output [6:0] seg,
    // buzzer
    output buzz,
    //output [1:0] object_color, station_color,
    // input [1:0] out_select,
    // output [7:0] cnt_out
    // input [3:0] state
    // output uturn_finished,

    output object_led, station_led

    //output temp
);

    // 1us, 1ms
    // wire clkus, clkms;
    Clkdiv #(6, 50) clk1 (.clk(clk), .nclk(clkus));
    Clkdiv #(10, 1000) clk2 (.clk(clkus), .nclk(clkms));

    wire [1:0] object_color, station_color;
    // wire end_of_track, uturn_finished, brake_finished, reverse_finished, buzz_finished, en_tracking, en_uturn, en_brake, en_reverse, en_buzz;
    wire [3:0] ssd_state;
    Core core (.rst(rst), .clk(clk), .hall(hall), .object_color(object_color), .station_color(station_color),
               .end_of_track(end_of_track), .uturn_finished(uturn_finished), .brake_finished(brake_finished), .reverse_finished(reverse_finished),
               .buzz_finished(buzz_finished), .en_tracking(en_tracking), .en_uturn(en_uturn), .en_brake(en_brake), .en_reverse(en_reverse),
               .ssd_state(ssd_state), .en_buzz(en_buzz), .en_object(en_object), .en_station(en_station));

    Color color (.clkus(clkus), .object_wave(object_wave), .station_wave(station_wave),
                 .object_select(object_select), .station_select(station_select), .object_color(object_color), .station_color(station_color),
                 .en_object(en_object), .en_station(en_station), .object_led(object_led), .station_led(station_led));

    Ssd ssd (.clkus(clkus), .clkms(clkms), .state(ssd_state), .bit(bit), .seg(seg));

    Buzzer buzzer (.clkms(clkms), .enable(en_buzz), .finished(buzz_finished), .buzz(buzz));

    wire [1:0] front_wheel, motor_speed;
    wire [3:0] ir;
    Deosc deosc3 (.clkus(clkus), .in(ir_in[3]), .out(ir[3]));
    Deosc deosc2 (.clkus(clkus), .in(ir_in[2]), .out(ir[2]));
    Deosc deosc1 (.clkus(clkus), .in(ir_in[1]), .out(ir[1]));
    Deosc deosc0 (.clkus(clkus), .in(ir_in[0]), .out(ir[0]));

    Trackuturn trackuturn (.rst(rst), .clkus(clkus), .ir(ir), .en_tracking(en_tracking), .en_uturn(en_uturn), .en_brake(en_brake), .en_reverse(en_reverse),
                           .front_wheel(front_wheel), .motor(motor_speed), .end_of_track(end_of_track), .uturn_finished(uturn_finished),
                           .brake_finished(brake_finished), .reverse_finished(reverse_finished));

    Servo servo (.clkus(clkus), .direction(front_wheel), .pwm(servo_pwm));

    Motor motor (.clkus(clkus), .speed(motor_speed), .motor_ctrl(motor_ctrl), .motor_en(motor_en));
endmodule