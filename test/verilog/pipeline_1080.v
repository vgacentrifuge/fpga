module pipeline_1080 (
                input clk,

                // The input position of the current pixel
                input [11:0] pixel_x,
                input [11:0] pixel_y,

                input [15:0] bg_pixel_in,
                input output_enable, // Whether we are blanking screen

                // Foreground coord sent to SRAM, pixel recieved
                input  [15:0] fg_pixel_in,
                input  fg_pixel_skip,
                output signed [12:0] fg_pixel_request_x,
                output signed [12:0] fg_pixel_request_y,
                output fg_pixel_request_active,
                
                // Resulting pixel. Positions for sanity checks.
                output reg [15:0] pixel_out,
                output reg [11:0] pixel_x_out,
                output reg [11:0] pixel_y_out,

                // Control signals:

                // How to merge the background and foreground
                // 0: No foreground
                // 1: Chroma key'd
                // 2: Direct overlay
                input [1:0] ctrl_overlay_mode,
                
                // Foreground scaling, i.e. if we should change the size of the foreground
                // See pipeline_foreground_scale.v for more info
                input [1:0] ctrl_fg_scale,

                // Foreground offsets, i.e. where to position the foreground on the screen
                // See pipeline_foreground_offset.v for more info
                input signed [12:0] ctrl_fg_offset_x,
                input signed [12:0] ctrl_fg_offset_y
                );

    pipeline #(
        .PRECISION(12),
        .RESOLUTION_X(1920),
        .RESOLUTION_Y(1080)
    ) handle(
        .clk(clk),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .bg_pixel_in(bg_pixel_in),
        .output_enable(output_enable),
        .fg_pixel_in(fg_pixel_in),
        .fg_pixel_skip(fg_pixel_skip),
        .fg_pixel_request_x(fg_pixel_request_x),
        .fg_pixel_request_y(fg_pixel_request_y),
        .fg_pixel_request_active(fg_pixel_request_active),
        .pixel_out(pixel_out),
        .pixel_x_out(pixel_x_out),
        .pixel_y_out(pixel_y_out),
        .ctrl_overlay_mode(ctrl_overlay_mode),
        .ctrl_fg_scale(ctrl_fg_scale),
        .ctrl_fg_offset_x(ctrl_fg_offset_x),
        .ctrl_fg_offset_y(ctrl_fg_offset_y)
    );
endmodule