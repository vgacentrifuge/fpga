module pipeline #(
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
    
    parameter FOREGROUND_FETCH_CYCLE_DELAY = 3, // The amount of cycles it takes for the foreground pixel value to be fetched

    parameter TRANSPARENCY_PRECISION = 3
) (
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
    input signed [PRECISION:0] ctrl_fg_offset_x,
    input signed [PRECISION:0] ctrl_fg_offset_y,

    input [TRANSPARENCY_PRECISION:0] ctrl_fg_opacity
);
    // Buffers while we wait for foreground pixel
    reg [PIXEL_SIZE * FOREGROUND_FETCH_CYCLE_DELAY:0] bg_pixel_buffer;
    reg [PRECISION * FOREGROUND_FETCH_CYCLE_DELAY:0] bg_pixel_x_buffer;
    reg [PRECISION * FOREGROUND_FETCH_CYCLE_DELAY:0] bg_pixel_y_buffer;

    // Handle foreground fetching
    pipeline_foreground_scale #(
        .PRECISION(PRECISION),
        .RESOLUTION_X(RESOLUTION_X),
        .RESOLUTION_Y(RESOLUTION_Y)
    ) fg_fetcher(
        .clk(clk),
        .output_enable(output_enable),
        .ctrl_foreground_scale(ctrl_fg_scale),
        .fg_offset_x(ctrl_fg_offset_x),
        .fg_offset_y(ctrl_fg_offset_y),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .fg_pixel_x(fg_pixel_request_x),
        .fg_pixel_y(fg_pixel_request_y),
        .fg_active(fg_pixel_request_active)
    );

    // Assuming here that a new pixel is ready every clock cycle
    always @(posedge clk)
    begin
        bg_pixel_buffer   <= {bg_pixel_buffer[PIXEL_SIZE * (FOREGROUND_FETCH_CYCLE_DELAY - 1):0], bg_pixel_in};
        bg_pixel_x_buffer <= {bg_pixel_x_buffer[PRECISION * (FOREGROUND_FETCH_CYCLE_DELAY - 1):0], pixel_x};
        bg_pixel_y_buffer <= {bg_pixel_y_buffer[PRECISION * (FOREGROUND_FETCH_CYCLE_DELAY - 1):0], pixel_y};
    end

    // The pixel we are currently processing
    wire [PIXEL_SIZE - 1:0] bg_pixel  = bg_pixel_buffer[PIXEL_SIZE * FOREGROUND_FETCH_CYCLE_DELAY - 1:PIXEL_SIZE * (FOREGROUND_FETCH_CYCLE_DELAY - 1)];
    wire [PRECISION - 1:0] bg_pixel_x = bg_pixel_x_buffer[PRECISION * FOREGROUND_FETCH_CYCLE_DELAY - 1:PRECISION * (FOREGROUND_FETCH_CYCLE_DELAY - 1)];
    wire [PRECISION - 1:0] bg_pixel_y = bg_pixel_y_buffer[PRECISION * FOREGROUND_FETCH_CYCLE_DELAY - 1:PRECISION * (FOREGROUND_FETCH_CYCLE_DELAY - 1)];

    wire [PIXEL_SIZE - 1:0] chroma_keyed_result;
    wire [PIXEL_SIZE - 1:0] overlayed_result;

    // Chroma keying
    pipeline_chroma_key #(
        .R_WIDTH(R_WIDTH),
        .G_WIDTH(G_WIDTH),
        .B_WIDTH(B_WIDTH),

        .RED_PASS(RED_PASS),
        .GREEN_PASS(GREEN_PASS),
        .BLUE_PASS(BLUE_PASS)
    ) chroma_keyer(
        .enable(~fg_pixel_skip), // Requires a valid foreground pixel
        .bg_pixel_in(bg_pixel),
        .fg_pixel_in(fg_pixel_in),
        .pixel_out(chroma_keyed_result)
    );

    // Overlaying
    pipeline_foreground_overlay #(
        .TRANSPARENCY_PRECISION(TRANSPARENCY_PRECISION),
        
        .R_WIDTH(R_WIDTH),
        .G_WIDTH(G_WIDTH),
        .B_WIDTH(B_WIDTH)
    ) overlayer(
        .enable(~fg_pixel_skip), // Requires a valid foreground pixel
        .bg_pixel_in(bg_pixel),
        .fg_pixel_in(fg_pixel_in),
        .pixel_out(overlayed_result),
        .fg_opacity(ctrl_fg_opacity)
    );

    // Output
    always @(posedge clk)
    begin
        pixel_x_out <= bg_pixel_x;
        pixel_y_out <= bg_pixel_y;

        if (~output_enable)
        begin
            pixel_out <= {PIXEL_SIZE{1'b0}};
        end
        else
        begin
            case (ctrl_overlay_mode)
                2'b01: pixel_out <= chroma_keyed_result;     // Chroma key
                2'b10: pixel_out <= overlayed_result;        // Overlay foreground
                default: pixel_out <= bg_pixel;
            endcase
        end
    end
endmodule
