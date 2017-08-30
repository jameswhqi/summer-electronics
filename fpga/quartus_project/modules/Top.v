// Top module
module Top
(
    // global reset
    input rst,
    // crystal clock of 50MHz
    input clk,
    // binary signals of 4 infrared sensors
    input [3:0] ir,
    // binary signal of hall sensor
    input hall,
    // square wave from color sensors
    input object_color
    input station_color
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

    Core core (.rst(rst), .clk(clk), .hall(hall), .object_color(object_color), .station_color(station_color),
               .end_of_track(end_of_track), .uturn_finished(uturn_finished), .buzz_finished(buzz_finished),
               .en_tracking(en_tracking), .en_uturn(en_uturn), .ssd_code(ssd_code), .en_buzz(en_buzz));

endmodule