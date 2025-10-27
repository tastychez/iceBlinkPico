module game_of_life (
    input logic clk,
    input logic [5:0] pixel,
    input logic [4:0] frame,
    output logic [7:0] red_data,
    output logic [7:0] green_data,
    output logic [7:0] blue_data
);

    // 8x8 grid for current and next generation
    logic [7:0] current_grid [0:7];
    logic [7:0] next_grid [0:7];
    
    // debug wires to view grid in gtkwave
    wire [7:0] DEBUG_ROW_0 = current_grid[0];
    wire [7:0] DEBUG_ROW_1 = current_grid[1];
    wire [7:0] DEBUG_ROW_2 = current_grid[2];
    wire [7:0] DEBUG_ROW_3 = current_grid[3];
    wire [7:0] DEBUG_ROW_4 = current_grid[4];
    wire [7:0] DEBUG_ROW_5 = current_grid[5];
    wire [7:0] DEBUG_ROW_6 = current_grid[6];
    wire [7:0] DEBUG_ROW_7 = current_grid[7];
    
    // rainbow color cycling
    logic [7:0] hue_counter = 8'd0;
    
    // convert pixel index to row and column
    logic [2:0] row, col;
    assign row = pixel[5:3];
    assign col = pixel[2:0];
    
    // previous frame tracker
    logic [4:0] prev_frame = 5'd31;
    
    // slow down generation updates (update every FRAMES_PER_GENERATION frames)
    localparam FRAMES_PER_GENERATION = 16;
    logic [3:0] frame_counter = 4'd0;
    
    // initialize grid state from file using $readmemh
    initial begin
        $readmemh("spiral/initial_state.txt", current_grid);
    end
    
    // update grid every FRAMES_PER_GENERATION frames
    always_ff @(posedge clk) begin
        logic [2:0] r, c, r_prev, r_next, c_prev, c_next;
        logic [3:0] neighbor_count;
        logic current_cell_state;
        
        // detect frame change (new frame started)
        if (frame != prev_frame) begin
            prev_frame <= frame;
            frame_counter <= frame_counter + 4'd1;
            
            // only compute next generation every FRAMES_PER_GENERATION frames
            if (frame_counter >= FRAMES_PER_GENERATION - 1) begin
                frame_counter <= 4'd0;
            
            // update all cells for next generation
            for (int i = 0; i < 8; i = i + 1) begin
                for (int j = 0; j < 8; j = j + 1) begin
                    r = i[2:0];
                    c = j[2:0];
                    
                    // cyclic boundary calculations
                    r_prev = (r == 3'd0) ? 3'd7 : r - 3'd1;
                    r_next = (r == 3'd7) ? 3'd0 : r + 3'd1;
                    c_prev = (c == 3'd0) ? 3'd7 : c - 3'd1;
                    c_next = (c == 3'd7) ? 3'd0 : c + 3'd1;
                    
                    // count living neighbors
                    neighbor_count = 4'd0;
                    if (current_grid[r_prev][c_prev]) neighbor_count = neighbor_count + 4'd1;
                    if (current_grid[r_prev][c]) neighbor_count = neighbor_count + 4'd1;
                    if (current_grid[r_prev][c_next]) neighbor_count = neighbor_count + 4'd1;
                    if (current_grid[r][c_prev]) neighbor_count = neighbor_count + 4'd1;
                    if (current_grid[r][c_next]) neighbor_count = neighbor_count + 4'd1;
                    if (current_grid[r_next][c_prev]) neighbor_count = neighbor_count + 4'd1;
                    if (current_grid[r_next][c]) neighbor_count = neighbor_count + 4'd1;
                    if (current_grid[r_next][c_next]) neighbor_count = neighbor_count + 4'd1;
                    
                    // apply conway's game of life rules
                    current_cell_state = current_grid[r][c];
                    if (current_cell_state == 1'b0) begin
                        // dead cell with exactly 3 neighbors becomes alive
                        next_grid[r][c] = (neighbor_count == 4'd3);
                    end else begin
                        // living cell survives with 2 or 3 neighbors
                        next_grid[r][c] = (neighbor_count == 4'd2) || (neighbor_count == 4'd3);
                    end
                end
            end
            
            // copy next generation to current
            for (int i = 0; i < 8; i = i + 1) begin
                current_grid[i] <= next_grid[i];
            end
            end
            
            // update rainbow hue every frame (independent of generation updates)
            hue_counter <= hue_counter + 8'd1;
        end
    end
    
    // generate rainbow colors based on hue_counter
    always_comb begin
        if (current_grid[row][col]) begin
            // living cell gets rainbow color cycling
            case (hue_counter[7:6])
                2'b00: begin
                    red_data = 8'd255;
                    green_data = hue_counter[5:0] << 2;
                    blue_data = 8'd0;
                end
                2'b01: begin
                    red_data = 8'd255 - (hue_counter[5:0] << 2);
                    green_data = 8'd255;
                    blue_data = 8'd0;
                end
                2'b10: begin
                    red_data = 8'd0;
                    green_data = 8'd255;
                    blue_data = hue_counter[5:0] << 2;
                end
                2'b11: begin
                    red_data = hue_counter[5:0] << 2;
                    green_data = 8'd255 - (hue_counter[5:0] << 2);
                    blue_data = 8'd255;
                end
            endcase
        end else begin
            // dead cell is black
            red_data = 8'd0;
            green_data = 8'd0;
            blue_data = 8'd0;
        end
    end

endmodule
