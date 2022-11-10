`include "src/pipeline/pipeline_foreground_scale.v"

// Special module for testing purposes with 1080p resolution
module pipeline_foreground_scale_1080(input clk,
                                 input [1:0] ctrl_foreground_scale,
                                 input [10:0] fg_offset_x,
                                 input [10:0] fg_offset_y,
                                 input [10:0] pixel_x,
                                 input [10:0] pixel_y,
                                 output reg [10:0] fg_pixel_x,
                                 output reg [10:0] fg_pixel_y,
                                 output fg_active);
    pipeline_foreground_scale #(.RESOLUTION_X(1920), .RESOLUTION_Y(1080), .PRECISION(11)) internal(
        .clk(clk),
        .ctrl_foreground_scale(ctrl_foreground_scale),
        .fg_offset_x(fg_offset_x),
        .fg_offset_y(fg_offset_y),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .fg_pixel_x(fg_pixel_x),
        .fg_pixel_y(fg_pixel_y),
        .fg_active(fg_active)
    );
endmodule