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
    
    parameter FOREGROUND_FETCH_CYCLE_DELAY = 6, // The amount of cycles it takes for the foreground pixel value to be fetched

    parameter TRANSPARENCY_PRECISION = 3
) (
    input clk,

    // The input position of the current bg pixel
    (* mark_debug = "true", keep = "true" *)
    input [PRECISION - 1:0] pixel_x,
    (* mark_debug = "true", keep = "true" *)
    input [PRECISION - 1:0] pixel_y,

    input [PIXEL_SIZE - 1:0] bg_pixel_in,
    // Determines if there is a bg pixel ready in bg_pixel_in
    (* mark_debug = "true", keep = "true" *)
    input bg_pixel_ready,
    // Whether we are blanking screen. This is used to skip a few steps
    // for those pixels. Only read when bg_pixel_ready is high
    input in_blanking_area,

    // Foreground coord sent to SRAM, pixel recieved
    input [PIXEL_SIZE - 1:0] fg_pixel_in,
    (* mark_debug = "true", keep = "true" *)
    input fg_pixel_skip,
    // Not every cycle will have a response to a request. This should be set
    // to high whenever there is a response ready, whether it be a skip or
    // pixel data. We expect this to be a response that comes exactly
    // FOREGROUND_FETCH_CYCLE_DELAY after the request was sent. If not, stuff
    // will break (massively)
    input fg_pixel_ready,
    
    (* mark_debug = "true", keep = "true" *)
    output signed [PRECISION:0] fg_pixel_request_x,
    (* mark_debug = "true", keep = "true" *)
    output signed [PRECISION:0] fg_pixel_request_y,
    (* mark_debug = "true", keep = "true" *)
    output fg_pixel_request_active,

    // Resulting pixel. Positions for sanity checks.
    (* mark_debug = "true", keep = "true" *)
    output reg [PIXEL_SIZE - 1:0] pixel_out,
    (* mark_debug = "true", keep = "true" *)
    output reg [PRECISION - 1:0] pixel_x_out,
    (* mark_debug = "true", keep = "true" *)
    output reg [PRECISION - 1:0] pixel_y_out,
    (* mark_debug = "true", keep = "true" *)
    output reg pixel_ready_out,

    // Control signals. See controlled_pipeline.v for more info
    input [1:0] ctrl_overlay_mode,
    input [1:0] ctrl_fg_scale,
    input signed [PRECISION:0] ctrl_fg_offset_x,
    input signed [PRECISION:0] ctrl_fg_offset_y,
    input [TRANSPARENCY_PRECISION:0] ctrl_fg_opacity,
    input [PRECISION - 1:0] ctrl_fg_clip_left,
    input [PRECISION - 1:0] ctrl_fg_clip_right,
    input [PRECISION - 1:0] ctrl_fg_clip_top,
    input [PRECISION - 1:0] ctrl_fg_clip_bottom
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
    reg [FOREGROUND_FETCH_CYCLE_DELAY - 1:0] bg_in_blanking_buffer;
    reg [FOREGROUND_FETCH_CYCLE_DELAY - 1:0] bg_pixel_ready_buffer;

    wire perform_foreground_fetch = (~in_blanking_area) & bg_pixel_ready;

    // Handle foreground fetching
    pipeline_foreground_scale #(
        .PRECISION(PRECISION),
        .RESOLUTION_X(RESOLUTION_X),
        .RESOLUTION_Y(RESOLUTION_Y)
    ) fg_fetcher(
        .clk(clk),
        .output_enable(perform_foreground_fetch),
        .ctrl_foreground_scale(ctrl_fg_scale),
        .fg_offset_x(ctrl_fg_offset_x),
        .fg_offset_y(ctrl_fg_offset_y),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .fg_pixel_x(fg_pixel_request_x),
        .fg_pixel_y(fg_pixel_request_y),
        .fg_active(fg_scale_request_active)
    );
    
(* mark_debug = "true", keep = "true" *)
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
    wire in_blanking_at_clk = bg_pixel_ready ? in_blanking_area : 1'b0;

    // Shift the bg pixel data into the buffers
    always @(posedge clk)
    begin
        bg_pixel_buffer       <= {bg_pixel_buffer[PIXEL_SIZE * (FOREGROUND_FETCH_CYCLE_DELAY - 1) - 1:0], bg_pixel_at_clk};
        bg_pixel_x_buffer     <= {bg_pixel_x_buffer[PRECISION * (FOREGROUND_FETCH_CYCLE_DELAY - 1) - 1:0], pixel_x_at_clk};
        bg_pixel_y_buffer     <= {bg_pixel_y_buffer[PRECISION * (FOREGROUND_FETCH_CYCLE_DELAY - 1) - 1:0], pixel_y_at_clk};
        bg_in_blanking_buffer <= {bg_in_blanking_buffer[FOREGROUND_FETCH_CYCLE_DELAY - 2:0], in_blanking_at_clk};
        bg_pixel_ready_buffer <= {bg_pixel_ready_buffer[FOREGROUND_FETCH_CYCLE_DELAY - 2:0], bg_pixel_ready};
    end

    // The pixel we are currently processing
    wire [PIXEL_SIZE - 1:0] bg_pixel  = bg_pixel_buffer[PIXEL_SIZE * FOREGROUND_FETCH_CYCLE_DELAY - 1:PIXEL_SIZE * (FOREGROUND_FETCH_CYCLE_DELAY - 1)];
    wire [PRECISION - 1:0] bg_pixel_x = bg_pixel_x_buffer[PRECISION * FOREGROUND_FETCH_CYCLE_DELAY - 1:PRECISION * (FOREGROUND_FETCH_CYCLE_DELAY - 1)];
    wire [PRECISION - 1:0] bg_pixel_y = bg_pixel_y_buffer[PRECISION * FOREGROUND_FETCH_CYCLE_DELAY - 1:PRECISION * (FOREGROUND_FETCH_CYCLE_DELAY - 1)];
    wire bg_blanking = bg_in_blanking_buffer[FOREGROUND_FETCH_CYCLE_DELAY - 1];
    wire buffer_bg_pixel_ready = bg_pixel_ready_buffer[FOREGROUND_FETCH_CYCLE_DELAY - 1];

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
        pixel_ready_out <= 1'b0;

        if (buffer_bg_pixel_ready) begin
            pixel_x_out <= bg_pixel_x;
            pixel_y_out <= bg_pixel_y;
            pixel_ready_out <= 1'b1;

            if (bg_blanking)
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
    end
endmodule
