// Cycles the on-board RGB LED: red, yellow, green, cyan, blue, magenta, repeat
// One full cycle per second on a 12 MHz iceBlinkPico board
// LED pins are active-low on this board, so we invert at the outputs

module top(
    input  logic clk,       
    output logic RGB_R,  
    output logic RGB_G,     
    output logic RGB_B      
);

    // 1 second at 12 MHz = 12,000,000 cycles
    parameter int ONE_SEC = 12_000_000;

    // 6 colors per second is about 0.166s each
    parameter int STEP = ONE_SEC / 6;  // = 2,000,000 cycles per color

    // counts cycles within one color
    logic [$clog2(STEP)-1:0] tick = '0;

    logic [2:0] color = 3'd0;     // which color (0..5)

    // 1 = ON in logic space
    logic r_on, g_on, b_on;

    always_comb begin
        unique case (color)
            3'd0: begin r_on=1; g_on=0; b_on=0; end // red
            3'd1: begin r_on=1; g_on=1; b_on=0; end // yellow
            3'd2: begin r_on=0; g_on=1; b_on=0; end // green
            3'd3: begin r_on=0; g_on=1; b_on=1; end // cyan
            3'd4: begin r_on=0; g_on=0; b_on=1; end // blue
            3'd5: begin r_on=1; g_on=0; b_on=1; end // magenta
            default: begin r_on=0; g_on=0; b_on=0; end // off
        endcase
    end

    always_ff @(posedge clk) begin
        if (tick == STEP-1) begin
            tick <= '0;

            if (color == 3'd5) begin
                color <= 3'd0;     // if we were at magenta, go back to red
            end else begin
                color <= color + 3'd1;  // otherwise just go to the next color
            end
        end else begin
            tick <= tick + 1'b1;   // keep counting until STEP-1
        end
    end


    // active low so drive 0 to turn LED ON
    assign RGB_R = ~r_on;
    assign RGB_G = ~g_on;
    assign RGB_B = ~b_on;

endmodule
