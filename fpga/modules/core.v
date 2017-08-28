// Core module
module Core
(
    // binary signal from hall sensor
    input hall,
    // encoded color type from Color module
    input [1:0] color,
    // feedback from Tracking module
    // end of track
    input end_of_track,
    // feedback from Uturn module
    // u-turn finished
    input uturn_finished,
    // enable Tracking module
    output en_tracking,
    // enable Uturn module
    output en_uturn,
    // status code to ssd control
    // 0 ready          1/2/3 sending red/green/blue    4/5/6 red/green/blue arrived
    // 7 end of track   8 u-turning                     9 returning
    output [3:0] ssd_code,
    // enable buzzer
    output buzz
);

    

endmodule