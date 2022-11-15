/*
 * This module is needed because we need to have 16 bits for the signed values,
 * otherwise the rounding will be different in the CPP test and in the verilog
 * implementation.
 */
module pipeline_spi_control_16b(
        input clk,
        
        output reg [1:0] ctrl_overlay_mode,        
        output reg [1:0] ctrl_fg_scale,

        output reg signed [15:0] ctrl_fg_offset_x,
        output reg signed [15:0] ctrl_fg_offset_y,

        output reg [14:0] ctrl_fg_clip_left,
        output reg [14:0] ctrl_fg_clip_right,
        output reg [14:0] ctrl_fg_clip_top,
        output reg [14:0] ctrl_fg_clip_bottom,

        // SPI HW interface
        input hw_spi_clk,
        input hw_spi_ss,
        input hw_spi_mosi,
        
        output hw_spi_miso
);
    pipeline_spi_control #(
        .PRECISION(15)
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
        .hw_spi_clk(hw_spi_clk),
        .hw_spi_ss(hw_spi_ss),
        .hw_spi_mosi(hw_spi_mosi),
        .hw_spi_miso(hw_spi_miso)
    );
endmodule