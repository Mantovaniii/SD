module train_game_with_vga(
    input logic CLOCK_50,           // Clock signal
    input logic reset,          // Reset button (KEY[0])
    output logic [7:0] VGA_R,       // VGA Red output
    output logic [7:0] VGA_G,       // VGA Green output
    output logic [7:0] VGA_B,       // VGA Blue output
    output logic VGA_HS,            // VGA Horizontal Sync
    output logic VGA_VS             // VGA Vertical Sync
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
        .clk(CLOCK_50),
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
        .clock_50Mhz(CLOCK_50),  // Usando o CLOCK_50 como clock para sincronização
        .red(red),
        .green(green),
        .blue(blue),
        .video_on(video_on),
        .red_out(VGA_R),         // Saída de cor para o VGA
        .green_out(VGA_G),
        .blue_out(VGA_B),
        .horiz_sync_out(VGA_HS), // Sinais de sincronização
        .vert_sync_out(VGA_VS),
        .pixel_row(pixel_row),
        .pixel_column(pixel_column)
    );

endmodule