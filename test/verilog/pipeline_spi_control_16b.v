/*
 * This module is needed because we need to have 16 bits for the signed values,
 * otherwise the rounding will be different in the CPP test and in the verilog
 * implementation.
 */
module pipeline_spi_control_16b(
        input clk,
        
        output ctrl_fg_freeze,

        output [1:0] ctrl_overlay_mode,        
        output [1:0] ctrl_fg_scale,

        output signed [15:0] ctrl_fg_offset_x,
        output signed [15:0] ctrl_fg_offset_y,

        output [14:0] ctrl_fg_clip_left,
        output [14:0] ctrl_fg_clip_right,
        output [14:0] ctrl_fg_clip_top,
        output [14:0] ctrl_fg_clip_bottom,
        
        output [2:0] ctrl_fg_transparency,

        // Image data sent over SPI
        output [14:0] ctrl_image_pixel_x,
        output [14:0] ctrl_image_pixel_y,
        output [15:0] ctrl_image_pixel,
        output ctrl_image_pixel_ready,

        // SPI HW interface
        input hw_spi_clk,
        input hw_spi_ss,
        input hw_spi_mosi,
        
        output hw_spi_miso
);
    pipeline_spi_control #(
        .PRECISION(15),
        .TRANSPARENCY_PRECISION(3),
        .PIXEL_SIZE(16),

        // Divided 1920 x 1080 by 4
        .RESOLUTION_X(480),
        .RESOLUTION_Y(270)
    ) spi_handle(
        .clk(clk),
        
        .ctrl_overlay_mode(ctrl_overlay_mode),
        .ctrl_fg_scale(ctrl_fg_scale),
        .ctrl_fg_offset_x(ctrl_fg_offset_x),
        .ctrl_fg_offset_y(ctrl_fg_offset_y),
        .ctrl_fg_clip_left(ctrl_fg_clip_left),
        .ctrl_fg_clip_right(ctrl_fg_clip_right),
        .ctrl_fg_clip_top(ctrl_fg_clip_top),
        .ctrl_fg_clip_bottom(ctrl_fg_clip_bottom),
        .ctrl_fg_transparency(ctrl_fg_transparency),
        .ctrl_fg_freeze(ctrl_fg_freeze),
        .ctrl_image_pixel_x(ctrl_image_pixel_x),
        .ctrl_image_pixel_y(ctrl_image_pixel_y),
        .ctrl_image_pixel(ctrl_image_pixel),
        .ctrl_image_pixel_ready(ctrl_image_pixel_ready),

        .hw_spi_clk(hw_spi_clk),
        .hw_spi_ss(hw_spi_ss),
        .hw_spi_mosi(hw_spi_mosi),
        .hw_spi_miso(hw_spi_miso)
    );
endmodule