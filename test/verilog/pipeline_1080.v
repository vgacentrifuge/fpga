module pipeline_1080 (
    input clk,

    // The input position of the current pixel
    input [11:0] pixel_x,
    input [11:0] pixel_y,

    input [15:0] bg_pixel_in,
    // Determines if there is a bg pixel ready in bg_pixel_in
    input bg_pixel_ready,
    // Whether we are blanking screen. This is used to skip a few steps
    // for those pixels. Only read when bg_pixel_ready is high
    input in_blanking_area,


    // Foreground coord sent to SRAM, pixel recieved
    input [15:0] fg_pixel_in,
    input fg_pixel_skip,
    // Not every cycle will have a response to a request. This should be set
    // to high whenever there is a response ready, whether it be a skip or
    // pixel data. We expect this to be a response that comes exactly
    // FOREGROUND_FETCH_CYCLE_DELAY after the request was sent. If not, stuff
    // will break (massively)
    input fg_pixel_ready,

    output signed [12:0] fg_pixel_request_x,
    output signed [12:0] fg_pixel_request_y,
    output fg_pixel_request_active,
    
    // Resulting pixel. Positions for sanity checks.
    output reg [15:0] pixel_out,
    output reg [11:0] pixel_x_out,
    output reg [11:0] pixel_y_out,
    output reg pixel_ready_out,

    // Control signals:
    input [1:0] ctrl_overlay_mode,
    input [1:0] ctrl_fg_scale,
    input signed [12:0] ctrl_fg_offset_x,
    input signed [12:0] ctrl_fg_offset_y,
    input [3:0] ctrl_fg_opacity,
    input [11:0] ctrl_fg_clip_left,
    input [11:0] ctrl_fg_clip_right,
    input [11:0] ctrl_fg_clip_top,
    input [11:0] ctrl_fg_clip_bottom
);

    pipeline #(
        .PRECISION(12),
        .RESOLUTION_X(1920),
        .RESOLUTION_Y(1080),
        .TRANSPARENCY_PRECISION(3)
    ) handle(
        .clk(clk),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .bg_pixel_in(bg_pixel_in),
        .bg_pixel_ready(bg_pixel_ready),
        .in_blanking_area(in_blanking_area),
        .fg_pixel_in(fg_pixel_in),
        .fg_pixel_skip(fg_pixel_skip),
        .fg_pixel_ready(fg_pixel_ready),
        .fg_pixel_request_x(fg_pixel_request_x),
        .fg_pixel_request_y(fg_pixel_request_y),
        .fg_pixel_request_active(fg_pixel_request_active),
        .pixel_out(pixel_out),
        .pixel_x_out(pixel_x_out),
        .pixel_y_out(pixel_y_out),
        .pixel_ready_out(pixel_ready_out),
        .ctrl_overlay_mode(ctrl_overlay_mode),
        .ctrl_fg_scale(ctrl_fg_scale),
        .ctrl_fg_offset_x(ctrl_fg_offset_x),
        .ctrl_fg_offset_y(ctrl_fg_offset_y),
        .ctrl_fg_opacity(ctrl_fg_opacity),
        .ctrl_fg_clip_left(ctrl_fg_clip_left),
        .ctrl_fg_clip_right(ctrl_fg_clip_right),
        .ctrl_fg_clip_top(ctrl_fg_clip_top),
        .ctrl_fg_clip_bottom(ctrl_fg_clip_bottom)
    );
endmodule