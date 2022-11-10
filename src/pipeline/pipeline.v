module pipeline(
                input clk,

                // The input position of the current pixel
                input [9:0] pixel_x,
                input [9:0] pixel_y,

                input [15:0] bg_pixel_in,
                input output_enable, // Whether we are blanking screen

                // Foreground coord sent to SRAM, pixel recieved
                input  [15:0] fg_pixel_in,
                input  fg_pixel_skip,
                output [9:0] fg_pixel_request_x,
                output [9:0] fg_pixel_request_x,
                output fg_pixel_request_active,
                
                // Resulting pixel. Positions for sanity checks.
                output reg [15:0] pixel_out,
                output reg [9:0] pixel_x_out,
                output reg [9:0] pixel_y_out,

                // Control signals:
                input [1:0] ctrl_overlay_mode,
                input [1:0] ctrl_fg_scale,
                input [9:0] ctrl_fg_offset_x,
                input [9:0] ctrl_fg_offset_y
                );
    parameter FOREGROUND_FETCH_CYCLE_DELAY = 4; // The amount of cycles it takes for the foreground pixel value to be fetched

    // Buffers while we wait for foreground pixel
    reg [(15 * FOREGROUND_FETCH_CYCLE_DELAY):0] bg_pixel_buffer;
    reg [(9 * FOREGROUND_FETCH_CYCLE_DELAY):0] bg_pixel_x_buffer;
    reg [(9 * FOREGROUND_FETCH_CYCLE_DELAY):0] bg_pixel_y_buffer;

    // Handle foreground fetching
    pipeline_foreground_scale fg_fetcher(
        .clk(clk),
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
        bg_pixel_buffer <= {bg_pixel_buffer[15 * (FOREGROUND_FETCH_CYCLE_DELAY - 1):0], bg_pixel_in};
        bg_pixel_x_buffer <= {bg_pixel_x_buffer[9 * (FOREGROUND_FETCH_CYCLE_DELAY - 1):0], pixel_x};
        bg_pixel_y_buffer <= {bg_pixel_y_buffer[9 * (FOREGROUND_FETCH_CYCLE_DELAY - 1):0], pixel_y};
    end

    // The pixel we are currently processing
    wire [15:0] bg_pixel = bg_pixel_buffer[15 * FOREGROUND_FETCH_CYCLE_DELAY:15 * (FOREGROUND_FETCH_CYCLE_DELAY - 1)];
    wire [9:0] bg_pixel_x = bg_pixel_x_buffer[9 * FOREGROUND_FETCH_CYCLE_DELAY:9 * (FOREGROUND_FETCH_CYCLE_DELAY - 1)];
    wire [9:0] bg_pixel_y = bg_pixel_y_buffer[9 * FOREGROUND_FETCH_CYCLE_DELAY:9 * (FOREGROUND_FETCH_CYCLE_DELAY - 1)];

    wire [15:0] chroma_keyed_result;
    wire [15:0] overlayed_result;

    // Chroma keying
    pipeline_chroma_key chroma_keyer(
        .enable(fg_pixel_in), // Requires a valid foreground pixel
        .bg_pixel_in(bg_pixel),
        .fg_pixel_in(fg_pixel_in),
        .pixel_out(chroma_keyed_result)
    );

    // Overlaying
    pipeline_foreground_overlay overlayer(
        .clk(clk),
        .enable(fg_pixel_in), // Requires a valid foreground pixel
        .bg_pixel_in(bg_pixel),
        .fg_pixel_in(fg_pixel_in),
        .pixel_out(overlayed_result)
    );

    // Output
    always @(posedge clk)
    begin
        pixel_x_out <= bg_pixel_x;
        pixel_y_out <= bg_pixel_y;

        if (~output_enable)
        begin
            pixel_out <= 16'b0;
        end
        else
        begin
            case (ctrl_overlay_mode)
                2'b00: pixel_out <= chroma_keyed_result; // Chroma key
                2'b01: pixel_out <= overlayed_result; // Overlay foreground
                default: pixel_out <= bg_pixel;
            endcase
        end
    end
endmodule
