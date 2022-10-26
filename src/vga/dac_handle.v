module dac_handle(
    input clk25, // 25 MHz clock

    input [15:0] pixel_in,
    /*
     * The x position of the pixel. This is used to synchronize the
     * pixel with the hsync/vsync signals. This has to include the 
     * sync + porches sections in the count.
     */
    input [9:0] pixel_x,
    /*
     * The y position of the pixel. See more information about use above.
     */
    input [9:0] pixel_y,

    output [15:0] hw_colour_bus,
    output hw_hsync_out,
    output hw_vsync_out,
    output hw_dacclk_out,
);
    reg [9:0] dac_position_x;
    reg [9:0] dac_position_y;

    reg in_display_area;

    wire hsync_gen;
    wire vsync_gen;

    signal_half_delay #(SHIFT_AMOUNT=7) hsync_delay(
        .clk(clk25),
        .signal_in(hsync_gen),
        .signal_out(hw_hsync_out),
    );

    signal_half_delay #(SHIFT_AMOUNT=7) vsync_delay(
        .clk(clk25),
        .signal_in(vsync_gen),
        .signal_out(hw_vsync_out),
    );

    hvsync_generator hvsync_generator(
        .clk25(clk25),
        .pixel_position_x(pixel_x),
        .pixel_position_y(pixel_y),
        .hw_vga_h_sync(hsync_gen),
        .hw_vga_v_sync(vsync_gen),
        .in_display_area(in_display_area)
    );

    always @(posedge clk25)
    begin
        if (in_display_area)
        begin
            hw_colour_bus <= pixel_in;
        end
        else
        begin
            // Set to black if the pixel is not in the display area as a safeguard
            hw_colour_bus <= 16'b0;
        end
    end

    assign hw_dacclk_out = clk25;
endmodule