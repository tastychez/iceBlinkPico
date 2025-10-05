`include "mp2.sv"
`include "pwm.sv"

// Fade top level module

module top #(
    parameter PWM_INTERVAL = 1200 // PWM period: 1200 cycles at 12MHz = 100us (10kHz PWM frequency)
)(
    input logic     clk,
    output logic    RGB_R, // Red LED output (active low)
    output logic    RGB_G, // Green LED output (active low)
    output logic    RGB_B // Blue LED output (active low)
);

    // Duty cycle values for each color channel (0 to PWM_INTERVAL-1)
    logic [$clog2(PWM_INTERVAL) - 1:0] red_duty;
    logic [$clog2(PWM_INTERVAL) - 1:0] green_duty;
    logic [$clog2(PWM_INTERVAL) - 1:0] blue_duty;
    logic red_signal;
    logic green_signal;
    logic blue_signal;

    mp2 #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u1 (
        .clk            (clk), 
        .pwm_valueR     (red_duty), 
        .pwm_valueG     (green_duty), 
        .pwm_valueB     (blue_duty)
    );

    // red channel PWM generator
    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u2 (
        .clk            (clk), 
        .pwm_value      (red_duty), 
        .pwm_out        (red_signal)
    );
    
    // green channel PWM generator
    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u3 (
        .clk            (clk), 
        .pwm_value      (green_duty), 
        .pwm_out        (green_signal)
    );
    
    // blue channel PWM generator
    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u4 (
        .clk            (clk), 
        .pwm_value      (blue_duty), 
        .pwm_out        (blue_signal)
    );

    // Invert PWM signals for common anode RGB LED configuration
    assign RGB_R = ~red_signal;   
    assign RGB_G = ~green_signal;
    assign RGB_B = ~blue_signal;

endmodule