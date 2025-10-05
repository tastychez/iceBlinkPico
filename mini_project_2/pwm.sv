// pwm.sv

module pwm #(
    parameter PWM_INTERVAL = 1200 // period in clock cycles (12 mhz / 1200 ≈ 10 khz)
)(
    input  logic clk, // 12 mhz clock input
    input  logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value, // duty value 0..PWM_INTERVAL-1
    output logic pwm_out // pwm bit output (active-high)
);

    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_count = 0; // pwm period counter

    always_ff @(posedge clk) begin
        if (pwm_count == PWM_INTERVAL - 1) begin
            pwm_count <= 0; // wrap at end of period
        end else begin
            pwm_count <= pwm_count + 1; // increment each clock
        end
    end

    // output is high while pwm_count <= pwm_value
    assign pwm_out = (pwm_count > pwm_value) ? 1'b0 : 1'b1;

endmodule
