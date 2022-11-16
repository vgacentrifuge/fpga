module controlled_pipeline #(
    parameter R_WIDTH = 5,
    parameter G_WIDTH = 6,
    parameter B_WIDTH = 5,

    localparam PIXEL_SIZE = R_WIDTH + G_WIDTH + B_WIDTH,

    parameter RED_PASS = 5'b00100,
    parameter GREEN_PASS = 6'b101100,
    parameter BLUE_PASS = 5'b01100,

    parameter PRECISION = 11,
    parameter RESOLUTION_X = 800,
    parameter RESOLUTION_Y = 600,
    
    parameter FOREGROUND_FETCH_CYCLE_DELAY = 3 // The amount of cycles it takes for the foreground pixel value to be fetched
)(
    input clk,

    // The input position of the current pixel
    input [PRECISION - 1:0] pixel_x,
    input [PRECISION - 1:0] pixel_y,

    input [PIXEL_SIZE - 1:0] bg_pixel_in,
    input output_enable, // Whether we are blanking screen

    // Foreground coord sent to SRAM, pixel recieved
    input  [PIXEL_SIZE - 1:0] fg_pixel_in,
    input  fg_pixel_skip,
    output signed [PRECISION:0] fg_pixel_request_x,
    output signed [PRECISION:0] fg_pixel_request_y,
    output fg_pixel_request_active,
    
    // Resulting pixel. Positions for sanity checks.
    output reg [PIXEL_SIZE - 1:0] pixel_out,
    output reg [PRECISION - 1:0] pixel_x_out,
    output reg [PRECISION - 1:0] pixel_y_out,

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
    reg [1:0] ctrl_overlay_mode;
    
    // Foreground scaling, i.e. if we should change the size of the foreground
    // See pipeline_foreground_scale.v for more info
    reg [1:0] ctrl_fg_scale;

    // Foreground offsets, i.e. where to position the foreground on the screen
    // See pipeline_foreground_offset.v for more info
    reg signed [PRECISION:0] ctrl_fg_offset_x;
    reg signed [PRECISION:0] ctrl_fg_offset_y;

    // Foreground clipping, i.e. how many pixels to remove from the foreground
    // on each side. Applies to the foreground coordinates before scaling, meaning 
    // that removing 4 pixels at quarter scale will yield in removing 1 actual 
    // foreground pixel that would otherwise be displayed
    reg [PRECISION - 1:0] ctrl_fg_clip_left;
    reg [PRECISION - 1:0] ctrl_fg_clip_right;
    reg [PRECISION - 1:0] ctrl_fg_clip_top;
    reg [PRECISION - 1:0] ctrl_fg_clip_bottom;

    // Pipeline module instance, using control values from above
    pipeline #(
        .R_WIDTH(R_WIDTH),
        .G_WIDTH(G_WIDTH),
        .B_WIDTH(B_WIDTH),
        
        .RED_PASS(RED_PASS),
        .GREEN_PASS(GREEN_PASS),
        .BLUE_PASS(BLUE_PASS),

        .PRECISION(PRECISION),
        .RESOLUTION_X(RESOLUTION_X),
        .RESOLUTION_Y(RESOLUTION_Y),

        .FOREGROUND_FETCH_CYCLE_DELAY(FOREGROUND_FETCH_CYCLE_DELAY)
    ) pipeline_handle(
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

    // SPI control module instance, assigning control values to above
    pipeline_spi_control #(
        .PRECISION(PRECISION)
    ) pipeline_spi_control_handle(
        .clk(clk),
        .ctrl_overlay_mode(ctrl_overlay_mode),
        .ctrl_fg_scale(ctrl_fg_scale),
        .ctrl_fg_offset_x(ctrl_fg_offset_x),
        .ctrl_fg_offset_y(ctrl_fg_offset_y),
        .hw_spi_clk(hw_spi_clk),
        .hw_spi_ss(hw_spi_ss),
        .hw_spi_mosi(hw_spi_mosi),
        .hw_spi_miso(hw_spi_miso)
    );
endmodule