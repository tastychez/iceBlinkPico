`include "game_of_life.sv"
`include "ws2812b.sv"
`include "controller.sv"

// top level module

module top(
    input logic     clk, 
    input logic     SW, 
    input logic     BOOT, 
    output logic    _48b, 
    output logic    _45a
);

    logic [7:0] red_data;
    logic [7:0] green_data;
    logic [7:0] blue_data;

    logic [5:0] pixel;
    logic [4:0] frame;

    logic [23:0] shift_reg = 24'd0;
    logic load_sreg;
    logic transmit_pixel;
    logic shift;
    logic ws2812b_out;

    // instance game of life module
    game_of_life u1 (
        .clk            (clk), 
        .pixel          (pixel), 
        .frame          (frame), 
        .red_data       (red_data),
        .green_data     (green_data),
        .blue_data      (blue_data)
    );

    // instance ws2812b output driver
    ws2812b u2 (
        .clk            (clk), 
        .serial_in      (shift_reg[23]), 
        .transmit       (transmit_pixel), 
        .ws2812b_out    (ws2812b_out), 
        .shift          (shift)
    );

    // instance controller
    controller u3 (
        .clk            (clk), 
        .load_sreg      (load_sreg), 
        .transmit_pixel (transmit_pixel), 
        .pixel          (pixel), 
        .frame          (frame)
    );

    always_ff @(posedge clk) begin
        if (load_sreg) begin
            // load full rgb data from game of life into shift register
            shift_reg <= { green_data, red_data, blue_data };
        end
        else if (shift) begin
            shift_reg <= { shift_reg[22:0], 1'b0 };
        end
    end

    assign _48b = ws2812b_out;
    assign _45a = ~ws2812b_out;

endmodule
