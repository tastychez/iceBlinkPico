// single-module rgb cycle that produces three pwm duty values (r g b)

module mp2 #(
    parameter int INC_DEC_INTERVAL = 20000, // clocks per small step
    parameter int PWM_ROUNDS       = 100, // number of steps per sector
    parameter int SECTORS          = 6, // sectors per full cycle
    parameter int PWM_INTERVAL     = 1200, // pwm period (clock cycles)
    parameter int STEP_VALUE       = PWM_INTERVAL / PWM_ROUNDS // duty increment
)(
    input  logic clk, // 12 mhz clock input
    output logic [$clog2(PWM_INTERVAL)-1:0] pwm_valueR, // red duty 0 - PWM_INTERVAL-1
    output logic [$clog2(PWM_INTERVAL)-1:0] pwm_valueG, // green duty 0 - PWM_INTERVAL-1
    output logic [$clog2(PWM_INTERVAL)-1:0] pwm_valueB  // blue duty 0 - PWM_INTERVAL-1
);

    // counters and state
    logic [$clog2(INC_DEC_INTERVAL)-1:0] step_count = 0; // clocks inside one step
    logic [$clog2(PWM_ROUNDS)-1:0] round_index = 0; // 0 - PWM_ROUNDS-1 inside sector
    logic [2:0] sector = 0; // 0 - SECTORS-1 global sector

    int up_val_int;
    int down_val_int;

    // initialize duties to start at red full
    initial begin
        pwm_valueR = PWM_INTERVAL - 1; // red full on at start
        pwm_valueG = 0;
        pwm_valueB = 0;
    end

    // tick every INC_DEC_INTERVAL clocks and update round_index / sector / duties
    always_ff @(posedge clk) begin
        if (step_count == INC_DEC_INTERVAL - 1) begin
            step_count <= 0;   

            // advance round index and wrap to next sector when needed
            if (round_index == PWM_ROUNDS - 1) begin
                round_index <= 0;
                if (sector == SECTORS - 1) sector <= 0;
                else sector <= sector + 1;
            end else begin
                round_index <= round_index + 1;
            end

            // compute up/down values for this small step
            up_val_int   = round_index * STEP_VALUE;                   
            down_val_int = (PWM_ROUNDS - 1 - round_index) * STEP_VALUE; // reversed ramp

            case (sector)
                3'd0: begin
                    // r = max, g up, b = 0
                    pwm_valueR <= PWM_INTERVAL - 1;
                    pwm_valueG <= up_val_int[$clog2(PWM_INTERVAL)-1:0];
                    pwm_valueB <= 0;
                end
                3'd1: begin
                    // r down , g = max, b = 0
                    pwm_valueR <= down_val_int[$clog2(PWM_INTERVAL)-1:0];
                    pwm_valueG <= PWM_INTERVAL - 1;
                    pwm_valueB <= 0;
                end
                3'd2: begin
                    // r = 0, g = max, b up
                    pwm_valueR <= 0;
                    pwm_valueG <= PWM_INTERVAL - 1;
                    pwm_valueB <= up_val_int[$clog2(PWM_INTERVAL)-1:0];
                end
                3'd3: begin
                    // r = 0, g down, b = max
                    pwm_valueR <= 0;
                    pwm_valueG <= down_val_int[$clog2(PWM_INTERVAL)-1:0];
                    pwm_valueB <= PWM_INTERVAL - 1;
                end
                3'd4: begin
                    // r up, g = 0, b = max
                    pwm_valueR <= up_val_int[$clog2(PWM_INTERVAL)-1:0];
                    pwm_valueG <= 0;
                    pwm_valueB <= PWM_INTERVAL - 1;
                end
                default: begin
                    // sector 5: r = max, g = 0, b down
                    pwm_valueR <= PWM_INTERVAL - 1;
                    pwm_valueG <= 0;
                    pwm_valueB <= down_val_int[$clog2(PWM_INTERVAL)-1:0];
                end
            endcase

        end else begin
            step_count <= step_count + 1; // step clock
        end
    end

endmodule