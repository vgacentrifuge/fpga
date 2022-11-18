module dac_handle (
    input pixelclk,

    input [15:0] pixel_in,
    /*
     * The x position of the pixel. This is used to synchronize the
     * pixel with the hsync/vsync signals. This has to include the 
     * sync + porches sections in the count.
     */
    input [10:0] pixel_x,
    /*
     * The y position of the pixel. See more information about use above.
     */
    input [10:0] pixel_y,

    input has_pixel,

    output reg [15:0] hw_colour_bus,
    output hw_hsync_out,
    output hw_vsync_out,
    output hw_dacclk_out
);
  wire in_display_area;

  wire hsync_gen;
  wire vsync_gen;

  signal_half_delay #(
      .SHIFT_AMOUNT(7)
  ) hsync_delay (
      .clk(pixelclk),
      .signal_in(hsync_gen),
      .signal_out(hw_hsync_out),
      .clamp(~has_pixel)
  );

  signal_half_delay #(
      .SHIFT_AMOUNT(7)
  ) vsync_delay (
      .clk(pixelclk),
      .signal_in(vsync_gen),
      .signal_out(hw_vsync_out),
      .clamp(~has_pixel)
  );

  hvsync_generator hvsync_generator (
      .clk(pixelclk),
      .pixel_position_x(pixel_x),
      .pixel_position_y(pixel_y),
      .vga_h_sync(hsync_gen),
      .vga_v_sync(vsync_gen),
      .in_display_area(in_display_area)
  );

  // Position pixel starting when clk goes high
  //    always @(posedge clk25) begin
  //        // Set to black if the pixel is not in the display area as a safeguard
  //        hw_colour_bus <= 16'b0;

  //        if (in_display_area)
  //        begin
  //            hw_colour_bus <= pixel_in;
  //        end

  //        x <= x+1;
  //        if(x+1 >= 1056) begin
  //            x <= 0;
  //            y <= y+1;
  //            if(y+1 >= 628) begin
  //                y <= 0;
  //            end
  //        end
  //    end
  always @(posedge pixelclk) begin
    hw_colour_bus <= 16'b0;
    if (in_display_area) begin
      hw_colour_bus <= pixel_in;
    end
  end
  assign hw_dacclk_out = pixelclk;
endmodule
