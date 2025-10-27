`timescale 1ns/1ns

module game_of_life_text_tb;

    // inputs to the module
    logic clk = 0;
    logic [5:0] pixel = 0;
    logic [4:0] frame = 0;
    
    // outputs
    logic [7:0] red_data, green_data, blue_data;

    // instantiate the unit under test
    game_of_life uut (
        .clk(clk),
        .pixel(pixel),
        .frame(frame),
        .red_data(red_data),
        .green_data(green_data),
        .blue_data(blue_data)
    );

    // clock generator
    always #5 clk = ~clk;

    // task to print the grid
    task print_grid (input int generation_num);
        string row_str;
        $display("--- Generation %0d ---", generation_num);
        for (int i = 0; i < 8; i = i + 1) begin
            row_str = "";
            for (int j = 0; j < 8; j = j + 1) begin
                if (uut.current_grid[i][j] == 1'b1) begin
                    row_str = {row_str, "[#]"};
                end else begin
                    row_str = {row_str, " . "};
                end
            end
            $display(row_str);
        end
        $display("--------------------");
    endtask


    // main test sequence
    initial begin
        $display("Starting Game of Life Text Simulation...");

        // manually set the initial grid state
        for (int i = 0; i < 8; i++) uut.current_grid[i] = 8'h00;
        uut.current_grid[2] = 8'h12;
        uut.current_grid[3] = 8'h08;
        uut.current_grid[4] = 8'h22;
        uut.current_grid[5] = 8'h1E;
        
        #1;

        // print the starting grid
        print_grid(0);

        // loop to simulate and print several generations
        for (int gen = 1; gen <= 5; gen = gen + 1) begin
            
            // update generation every 16 frames
            for (int f = 0; f < 16; f = f + 1) begin
                frame = frame + 1;
                @(posedge clk);
            end
            
            // wait one extra tick for update to finish
            frame = frame + 1;
            @(posedge clk);
            
            #1;
            
            // print the new grid
            print_grid(gen);
        end

        // finish simulation
        $display("...Simulation Complete.");
        $finish;
    end

endmodule



