module dac_handle #(
    parameter PRECISION = 11,
    parameter PIXEL_SIZE = 16,
    
    parameter X_RES = 800,
    parameter Y_RES = 600,
    
    parameter H_SYNC = 128,
    parameter V_SYNC = 4,
    
    parameter H_FRONT_PORCH = 40,
    parameter V_FRONT_PORCH = 1
) (
    input pixelclk,

    input [PIXEL_SIZE - 1:0] pixel_in,
    /*
     * The x position of the pixel. This is used to synchronize the
     * pixel with the hsync/vsync signals. This has to include the 
     * sync + porches sections in the count.
     */
    input [PRECISION - 1:0] pixel_x,
    /*
     * The y position of the pixel. See more information about use above.
     */
    input [PRECISION - 1:0] pixel_y,
    
    input has_pixel,

    output reg [PIXEL_SIZE - 1:0] hw_colour_bus,
    output hw_hsync_out,
    output hw_vsync_out,
    output hw_dacclk_out
);
    wire in_display_area;

    wire hsync_gen;
    wire vsync_gen;

    signal_half_delay #(.SHIFT_AMOUNT(7)) hsync_delay(
        .clk(pixelclk),
        .signal_in(hsync_gen),
        .signal_out(hw_hsync_out),
        .clamp(~has_pixel)
    );

    signal_half_delay #(.SHIFT_AMOUNT(7)) vsync_delay(
        .clk(pixelclk),
        .signal_in(vsync_gen),
        .signal_out(hw_vsync_out),
        .clamp(~has_pixel)
    );

    hvsync_generator #(
        .PRECISION(PRECISION),

        .X_RES(X_RES),
        .Y_RES(Y_RES),

        .H_SYNC(H_SYNC),
        .V_SYNC(V_SYNC),

        .H_FRONT_PORCH(H_FRONT_PORCH),
        .V_FRONT_PORCH(V_FRONT_PORCH)
    ) hvsync_generator(
        .clk(pixelclk),
        .pixel_position_x(pixel_x),
        .pixel_position_y(pixel_y),
        .vga_h_sync(hsync_gen),
        .vga_v_sync(vsync_gen),
        .in_display_area(in_display_area)
    );

    always @(posedge pixelclk) begin
        hw_colour_bus <= {PIXEL_SIZE{1'b0}};
        if (in_display_area) begin
            hw_colour_bus <= pixel_in;
        end
    end
    
    assign hw_dacclk_out = pixelclk;
endmodule
