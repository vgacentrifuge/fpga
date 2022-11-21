module pipeline #(
    parameter R_WIDTH = 5,
    parameter G_WIDTH = 6,
    parameter B_WIDTH = 5,

    localparam PIXEL_SIZE = R_WIDTH + G_WIDTH + B_WIDTH,

    parameter PRECISION = 11,
    parameter RESOLUTION_X = 800,
    parameter RESOLUTION_Y = 600,
    
    parameter FOREGROUND_FETCH_CYCLE_DELAY = 6, // The amount of cycles it takes for the foreground pixel value to be fetched

    parameter TRANSPARENCY_PRECISION = 3
) (
    input clk,

    // The input position of the current bg pixel
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
    output reg [PRECISION - 1:0] pixel_x_out,
    output reg [PRECISION - 1:0] pixel_y_out,
    output reg pixel_ready_out,

    // Control signals. See controlled_pipeline.v for more info
    input [1:0] ctrl_overlay_mode,
    input [1:0] ctrl_fg_scale,
    input signed [PRECISION:0] ctrl_fg_offset_x,
    input signed [PRECISION:0] ctrl_fg_offset_y,
    input [TRANSPARENCY_PRECISION - 1:0] ctrl_fg_transparency,
    input [PRECISION - 1:0] ctrl_fg_clip_left,
    input [PRECISION - 1:0] ctrl_fg_clip_right,
    input [PRECISION - 1:0] ctrl_fg_clip_top,
    input [PRECISION - 1:0] ctrl_fg_clip_bottom,
    input [PIXEL_SIZE - 1:0] ctrl_green_screen_filter
);
    // Buffers while we wait for foreground pixel. These will mostly contain just zeros,
    // but I can't think of a cleaner way to handle this. The flow right now is that we
    // append background pixel data in these buffers if bg_pixel_ready is high, otherwise
    // we just fill them with zeros. That way, when the fg pixel is ready, the correct bg
    // pixel data is in the MSBs of these buffers. This also means that the timing of the
    // bg pixel readiness wont matter, since there is no way for it to have a higher 
    // frequency than clk.
    reg [PIXEL_SIZE * FOREGROUND_FETCH_CYCLE_DELAY - 1:0] bg_pixel_buffer;
    reg [PRECISION * FOREGROUND_FETCH_CYCLE_DELAY - 1:0] bg_pixel_x_buffer;
    reg [PRECISION * FOREGROUND_FETCH_CYCLE_DELAY - 1:0] bg_pixel_y_buffer;
    reg [FOREGROUND_FETCH_CYCLE_DELAY - 1:0] bg_pixel_ready_buffer;

    // --------------------
    // Initial processing; Calculating foreground pixel position and requesting it
    // --------------------

    // Handle foreground fetching
    pipeline_foreground_scale #(
        .PRECISION(PRECISION),
        .RESOLUTION_X(RESOLUTION_X),
        .RESOLUTION_Y(RESOLUTION_Y)
    ) fg_fetcher(
        .clk(clk),
        .output_enable(bg_pixel_ready),
        .ctrl_foreground_scale(ctrl_fg_scale),
        .fg_offset_x(ctrl_fg_offset_x),
        .fg_offset_y(ctrl_fg_offset_y),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .fg_pixel_x(fg_pixel_request_x),
        .fg_pixel_y(fg_pixel_request_y),
        .fg_active(fg_scale_request_active)
    );
    
    wire fg_scale_request_active;

    // Handle foreground clipping
    pipeline_foreground_clip #(
        .PRECISION(PRECISION),
        .RESOLUTION_X(RESOLUTION_X),
        .RESOLUTION_Y(RESOLUTION_Y)
    ) fg_clipper(
        .in_fg_request_active(fg_scale_request_active),
        .fg_pixel_x(fg_pixel_request_x),
        .fg_pixel_y(fg_pixel_request_y),
        .ctrl_fg_clip_left(ctrl_fg_clip_left),
        .ctrl_fg_clip_right(ctrl_fg_clip_right),
        .ctrl_fg_clip_top(ctrl_fg_clip_top),
        .ctrl_fg_clip_bottom(ctrl_fg_clip_bottom),
        .out_fg_request_active(fg_pixel_request_active)
    );

    // Wires that are either 0, or the background pixel data if available
    wire [PIXEL_SIZE - 1:0] bg_pixel_at_clk = bg_pixel_ready ? bg_pixel_in : {PIXEL_SIZE{1'b0}};
    wire [PRECISION - 1:0] pixel_x_at_clk = bg_pixel_ready ? pixel_x : {PRECISION{1'b0}};
    wire [PRECISION - 1:0] pixel_y_at_clk = bg_pixel_ready ? pixel_y : {PRECISION{1'b0}};

    // Shift the bg pixel data into the buffers
    always @(posedge clk)
    begin
        bg_pixel_buffer       <= {bg_pixel_buffer[PIXEL_SIZE * (FOREGROUND_FETCH_CYCLE_DELAY - 1) - 1:0], bg_pixel_at_clk};
        bg_pixel_x_buffer     <= {bg_pixel_x_buffer[PRECISION * (FOREGROUND_FETCH_CYCLE_DELAY - 1) - 1:0], pixel_x_at_clk};
        bg_pixel_y_buffer     <= {bg_pixel_y_buffer[PRECISION * (FOREGROUND_FETCH_CYCLE_DELAY - 1) - 1:0], pixel_y_at_clk};
        bg_pixel_ready_buffer <= {bg_pixel_ready_buffer[FOREGROUND_FETCH_CYCLE_DELAY - 2:0], bg_pixel_ready};
    end

    // --------------------
    // Final processing; Merging foreground and background pixels according to ctrl regs
    // --------------------

    // The pixel we are currently processing
    wire [PIXEL_SIZE - 1:0] bg_pixel  = bg_pixel_buffer[PIXEL_SIZE * FOREGROUND_FETCH_CYCLE_DELAY - 1:PIXEL_SIZE * (FOREGROUND_FETCH_CYCLE_DELAY - 1)];
    wire [PRECISION - 1:0] bg_pixel_x = bg_pixel_x_buffer[PRECISION * FOREGROUND_FETCH_CYCLE_DELAY - 1:PRECISION * (FOREGROUND_FETCH_CYCLE_DELAY - 1)];
    wire [PRECISION - 1:0] bg_pixel_y = bg_pixel_y_buffer[PRECISION * FOREGROUND_FETCH_CYCLE_DELAY - 1:PRECISION * (FOREGROUND_FETCH_CYCLE_DELAY - 1)];
    wire buffer_bg_pixel_ready = bg_pixel_ready_buffer[FOREGROUND_FETCH_CYCLE_DELAY - 1];

    wire use_fg_pixel_chroma;
    wire use_fg_pixel_overlay;

    // Chroma keying
    pipeline_mode_chroma_key #(
        .R_WIDTH(R_WIDTH),
        .G_WIDTH(G_WIDTH),
        .B_WIDTH(B_WIDTH)
    ) chroma_keyer(
        .fg_pixel_ready(fg_pixel_ready), // Requires a valid foreground pixel
        .bg_pixel_in(bg_pixel),
        .fg_pixel_in(fg_pixel_in),
        .ctrl_green_screen_filter(ctrl_green_screen_filter),
        .use_fg_pixel(use_fg_pixel_chroma)
    );

    // Overlaying
    pipeline_mode_overlay #(
        .PIXEL_SIZE(PIXEL_SIZE)
    ) overlayer(
        .fg_pixel_ready(fg_pixel_ready), // Requires a valid foreground pixel
        .use_fg_pixel(use_fg_pixel_overlay)
    );

    reg merge_use_fg_pixel;
    reg [PIXEL_SIZE - 1:0] merge_fg_pixel;
    reg [PIXEL_SIZE - 1:0] merge_bg_pixel;

    // Merge the pixels
    pipeline_pixel_merger #(
        .TRANSPARENCY_PRECISION(TRANSPARENCY_PRECISION),

        .R_WIDTH(R_WIDTH),
        .G_WIDTH(G_WIDTH),
        .B_WIDTH(B_WIDTH)
    ) merger(
        .use_fg_pixel(merge_use_fg_pixel),
        .fg_pixel_in(merge_fg_pixel),
        .bg_pixel_in(merge_bg_pixel),
        .ctrl_fg_transparency(ctrl_fg_transparency),
        .pixel_out(pixel_out)
    );

    // Different modes
    localparam MODE_OVERLAY    = 2'b01;
    localparam MODE_CHROMA_KEY = 2'b10;

    // Output
    always @(posedge clk)
    begin
        pixel_ready_out <= 1'b0;

        if (buffer_bg_pixel_ready) begin
            pixel_x_out <= bg_pixel_x;
            pixel_y_out <= bg_pixel_y;

            merge_fg_pixel <= fg_pixel_in;
            merge_bg_pixel <= bg_pixel;
            
            pixel_ready_out <= 1'b1;

            case (ctrl_overlay_mode)
                MODE_OVERLAY: merge_use_fg_pixel <= use_fg_pixel_overlay;        
                MODE_CHROMA_KEY: merge_use_fg_pixel <= use_fg_pixel_chroma;     
                default: merge_use_fg_pixel <= 1'b0;
            endcase
        end
    end
endmodule
