
module train_game_with_vga(
    input logic clk,               // Clock signal
    input logic reset,             // Reset signal
    output logic [7:0] VGA_R,      // VGA Red output
    output logic [7:0] VGA_G,      // VGA Green output
    output logic [7:0] VGA_B,      // VGA Blue output
    output logic VGA_HS,           // VGA Horizontal Sync
    output logic VGA_VS            // VGA Vertical Sync
);

    // Internal signals for VGA_SYNC
    logic [9:0] pixel_row;
    logic [9:0] pixel_column;
    logic [7:0] red;
    logic [7:0] green;
    logic [7:0] blue;
    logic video_on;

    // Instantiate the train game logic
    train_game_logic game_logic_inst (
        .clk(clk),
        .reset(reset),
        .pixel_row(pixel_row),
        .pixel_column(pixel_column),
        .red(red),
        .green(green),
        .blue(blue),
        .video_on(video_on)
    );

    // Instantiate the VGA Synchronization module
    VGA_SYNC vga_sync_inst (
        .clock_50Mhz(clk), // Pixel clock input
        .red(red),         // Red input from game logic
        .green(green),     // Green input from game logic
        .blue(blue),       // Blue input from game logic
        .red_out(VGA_R),   // Red output to VGA
        .green_out(VGA_G), // Green output to VGA
        .blue_out(VGA_B),  // Blue output to VGA
        .horiz_sync_out(VGA_HS), // Horizontal sync output
        .vert_sync_out(VGA_VS),  // Vertical sync output
        .video_on(video_on),
        .pixel_row(pixel_row),
        .pixel_column(pixel_column)
    );

endmodule
