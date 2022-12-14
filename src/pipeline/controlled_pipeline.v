module controlled_pipeline #(
    parameter R_WIDTH = 5,
    parameter G_WIDTH = 6,
    parameter B_WIDTH = 5,

    localparam PIXEL_SIZE = R_WIDTH + G_WIDTH + B_WIDTH,

    // The amount of bits we use to represent an unsigned position on the screen
    parameter PRECISION = 11,
    
    parameter RESOLUTION_X = 800,
    parameter RESOLUTION_Y = 600,

    // The amount of cycles it takes for the foreground pixel value to be fetched
    parameter FOREGROUND_FETCH_CYCLE_DELAY = 5,

    // The amount of bits to use for the transparency value. We actually use one
    // more than this value, but don't worry too much about that :)
    // Explanation in transparency_colour_channel.v
    parameter TRANSPARENCY_PRECISION = 3
)(
    input clk,

    // The input position of the current pixel
    input [PRECISION - 1:0] pixel_x,
    input [PRECISION - 1:0] pixel_y,

    input [PIXEL_SIZE - 1:0] bg_pixel_in,
    // Determines if there is a bg pixel ready in bg_pixel_in
    input bg_pixel_ready,


    // Foreground coord sent to SRAM, pixel recieved
    input [PIXEL_SIZE - 1:0] fg_pixel_in,
    // Determines if there is a fg pixel ready in fg_pixel_in
    input fg_pixel_ready,

    output signed [PRECISION:0] fg_pixel_request_x,
    output signed [PRECISION:0] fg_pixel_request_y,
    output fg_pixel_request_active,
    
    // Resulting pixel. Positions for sanity checks.
    output [PIXEL_SIZE - 1:0] pixel_out,
    output [PRECISION - 1:0] pixel_x_out,
    output [PRECISION - 1:0] pixel_y_out,
    output pixel_ready_out,

    output ctrl_fg_freeze,

    // Image data sent over SPI
    output [PRECISION - 1:0] ctrl_image_pixel_x,
    output [PRECISION - 1:0] ctrl_image_pixel_y,
    output [PIXEL_SIZE - 1:0] ctrl_image_pixel,
    output ctrl_image_pixel_ready,

    // SPI HW interface
    input hw_spi_clk,
    input hw_spi_ss,
    input hw_spi_mosi,
    
    output hw_spi_miso
);
    // How to merge the background and foreground
    // 0: No foreground
    // 1: Chroma key'd
    // 2: Direct overlay
    wire [1:0] ctrl_overlay_mode;
    
    // Foreground scaling, i.e. if we should change the size of the foreground
    // See pipeline_foreground_scale.v for more info
    wire [1:0] ctrl_fg_scale;

    // Foreground offsets, i.e. where to position the foreground on the screen
    // See pipeline_foreground_offset.v for more info
    wire signed [PRECISION:0] ctrl_fg_offset_x;
    wire signed [PRECISION:0] ctrl_fg_offset_y;

    // Foreground transparency. 0 means that the foreground is completely
    // opaque
    wire [TRANSPARENCY_PRECISION - 1:0] ctrl_fg_transparency;
    // The filter used for green screen. See pipeline_mode_chroma_key.v for details.
    // Consists of 3 parts, R, G, B with 5, 6, 5 bits respectively. The R and B values
    // are upper limits, while the G value is a lower limit for what is considered green
    // screen.
    wire [PIXEL_SIZE - 1:0] ctrl_green_screen_filter;

    // Foreground clipping, i.e. how many pixels to remove from the foreground
    // on each side. Applies to the foreground coordinates before scaling, meaning 
    // that removing 4 pixels at quarter scale will yield in removing 1 actual 
    // foreground pixel that would otherwise be displayed
    wire [PRECISION - 1:0] ctrl_fg_clip_left;
    wire [PRECISION - 1:0] ctrl_fg_clip_right;
    wire [PRECISION - 1:0] ctrl_fg_clip_top;
    wire [PRECISION - 1:0] ctrl_fg_clip_bottom;

    // Pipeline module instance, using control values from above
    pipeline #(
        .R_WIDTH(R_WIDTH),
        .G_WIDTH(G_WIDTH),
        .B_WIDTH(B_WIDTH),

        .PRECISION(PRECISION),
        .RESOLUTION_X(RESOLUTION_X),
        .RESOLUTION_Y(RESOLUTION_Y),

        .FOREGROUND_FETCH_CYCLE_DELAY(FOREGROUND_FETCH_CYCLE_DELAY)
    ) pipeline_handle(
        .clk(clk),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        
        .bg_pixel_in(bg_pixel_in),
        .bg_pixel_ready(bg_pixel_ready),
        
        .fg_pixel_in(fg_pixel_in),
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
        .ctrl_fg_transparency(ctrl_fg_transparency),
        .ctrl_fg_clip_left(ctrl_fg_clip_left),
        .ctrl_fg_clip_right(ctrl_fg_clip_right),
        .ctrl_fg_clip_top(ctrl_fg_clip_top),
        .ctrl_fg_clip_bottom(ctrl_fg_clip_bottom),
        .ctrl_green_screen_filter(ctrl_green_screen_filter)
    );

    // SPI control module instance, assigning control values to above
    pipeline_spi_control #(
        .PRECISION(PRECISION),
        .PIXEL_SIZE(PIXEL_SIZE),

        .RESOLUTION_X(RESOLUTION_X),
        .RESOLUTION_Y(RESOLUTION_Y)
    ) pipeline_spi_control_handle(
        .clk(clk),
        
        .ctrl_fg_freeze(ctrl_fg_freeze),
        .ctrl_overlay_mode(ctrl_overlay_mode),
        .ctrl_fg_scale(ctrl_fg_scale),
        .ctrl_fg_offset_x(ctrl_fg_offset_x),
        .ctrl_fg_offset_y(ctrl_fg_offset_y),
        
        .ctrl_fg_transparency(ctrl_fg_transparency),
        .ctrl_green_screen_filter(ctrl_green_screen_filter),

        .ctrl_fg_clip_left(ctrl_fg_clip_left),
        .ctrl_fg_clip_right(ctrl_fg_clip_right),
        .ctrl_fg_clip_top(ctrl_fg_clip_top),
        .ctrl_fg_clip_bottom(ctrl_fg_clip_bottom),

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
