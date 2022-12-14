module pipeline_spi_control #(
    parameter PRECISION = 11,
    parameter PIXEL_SIZE = 16,
    parameter TRANSPARENCY_PRECISION = 3,

    parameter RESOLUTION_X = 800,
    parameter RESOLUTION_Y = 600
)(
        input clk,
        
        output reg ctrl_fg_freeze,
        output reg [1:0] ctrl_overlay_mode,     
        output reg [1:0] ctrl_fg_scale,

        output reg signed [PRECISION:0] ctrl_fg_offset_x,
        output reg signed [PRECISION:0] ctrl_fg_offset_y,

        output reg [PRECISION - 1:0] ctrl_fg_clip_left,
        output reg [PRECISION - 1:0] ctrl_fg_clip_right,
        output reg [PRECISION - 1:0] ctrl_fg_clip_top,
        output reg [PRECISION - 1:0] ctrl_fg_clip_bottom,
        
        output reg [TRANSPARENCY_PRECISION - 1:0] ctrl_fg_transparency,
        output reg [PIXEL_SIZE - 1:0] ctrl_green_screen_filter,

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
    // Command identifiers
    localparam CMD_RESET = 8'h00;
    localparam CMD_SET_FOREGROUND_MODE = 8'h01;
    localparam CMD_SET_FOREGROUND_FLAGS = 8'h02; // Unused
    localparam CMD_SET_FOREGROUND_SCALE = 8'h03;
    localparam CMD_SET_FOREGROUND_OFFSET_X = 8'h04;
    localparam CMD_SET_FOREGROUND_OFFSET_Y = 8'h05;
    localparam CMD_SET_FOREGROUND_TRANSPARENCY = 8'h06;
    localparam CMD_SET_FOREGROUND_CLIP_LEFT = 8'h07;
    localparam CMD_SET_FOREGROUND_CLIP_RIGHT = 8'h08;
    localparam CMD_SET_FOREGROUND_CLIP_TOP = 8'h09;
    localparam CMD_SET_FOREGROUND_CLIP_BOTTOM = 8'h0A;
    localparam CMD_SET_FOREGROUND_FREEZE = 8'h0B;
    localparam CMD_START_IMAGE_UPLOAD = 8'h0C; 
    localparam CMD_CHROMA_KEY_FLIP_FG_BG = 8'h0D; // Unused
    localparam CMD_CHROMA_KEY_SET_FILTER = 8'h0E;
    localparam CMD_NO_OP = 8'hFF;

    // Command processing states
    localparam STATE_AWAITING_COMMAND = 3'b000;
    localparam STATE_AWAITING_DATA_1 = 3'b001;
    localparam STATE_AWAITING_DATA_2 = 3'b010;
    localparam STATE_AWAITING_IMAGE = 3'b011;
    localparam STATE_AWAITING_PROCESSING = 3'b101;

    // Function for processing the commands. Allows us to keep the logic
    // here and not in the state machine
    function [2:0] process_command(input [7:0] command_buffer, input [15:0] argument_buffer); begin
        case (command_buffer)
            CMD_RESET: begin
                ctrl_overlay_mode = 2'b00;
                ctrl_fg_scale = 2'b00;
                ctrl_fg_offset_x = {PRECISION + 1{1'b0}};
                ctrl_fg_offset_y = {PRECISION + 1{1'b0}};
                ctrl_fg_clip_left = {PRECISION{1'b0}};
                ctrl_fg_clip_right = {PRECISION{1'b0}};
                ctrl_fg_clip_top = {PRECISION{1'b0}};
                ctrl_fg_clip_bottom = {PRECISION{1'b0}};
                ctrl_fg_freeze = 1'b0;
                ctrl_green_screen_filter = 16'b0010010110001100;
            end
            CMD_SET_FOREGROUND_MODE: begin
                ctrl_overlay_mode = argument_buffer[1:0];
            end
            CMD_SET_FOREGROUND_SCALE: begin
                ctrl_fg_scale = argument_buffer[1:0];
            end
            CMD_SET_FOREGROUND_OFFSET_X: begin
                ctrl_fg_offset_x = argument_buffer[PRECISION:0];
            end
            CMD_SET_FOREGROUND_OFFSET_Y: begin
                ctrl_fg_offset_y = argument_buffer[PRECISION:0];
            end
            CMD_SET_FOREGROUND_CLIP_LEFT: begin
                ctrl_fg_clip_left = argument_buffer[PRECISION - 1:0];
            end
            CMD_SET_FOREGROUND_CLIP_RIGHT: begin
                ctrl_fg_clip_right = argument_buffer[PRECISION - 1:0];
            end
            CMD_SET_FOREGROUND_CLIP_TOP: begin
                ctrl_fg_clip_top = argument_buffer[PRECISION - 1:0];
            end
            CMD_SET_FOREGROUND_CLIP_BOTTOM: begin
                ctrl_fg_clip_bottom = argument_buffer[PRECISION - 1:0];
            end
            CMD_SET_FOREGROUND_FREEZE: begin
                ctrl_fg_freeze = argument_buffer[0];
            end
            CMD_SET_FOREGROUND_TRANSPARENCY: begin
                ctrl_fg_transparency = argument_buffer[TRANSPARENCY_PRECISION - 1:0];
            end
            CMD_CHROMA_KEY_SET_FILTER: begin
                ctrl_green_screen_filter = argument_buffer[PIXEL_SIZE - 1:0];
            end
            default: begin
                // Do nothing
            end
        endcase

        process_command = STATE_AWAITING_COMMAND;
        end
    endfunction

    reg [7:0] command_buffer;
    reg [15:0] argument_buffer;
    reg [2:0] command_state;

    wire [7:0] byte_out;
    wire byte_ready;

    // This is a special check that will only be executed when the
    // command first arrives. Since the command buffer is not assigned
    // at this point, we have to use byte_out instead.
    wire is_no_arg = (byte_out == CMD_RESET) 
                   | (byte_out == CMD_NO_OP);

    wire is_one_arg = (command_buffer == CMD_SET_FOREGROUND_MODE)
                    | (command_buffer == CMD_SET_FOREGROUND_FLAGS) 
                    | (command_buffer == CMD_SET_FOREGROUND_SCALE) 
                    | (command_buffer == CMD_SET_FOREGROUND_TRANSPARENCY)
                    | (command_buffer == CMD_SET_FOREGROUND_FREEZE); 
    wire is_two_arg = (command_buffer == CMD_SET_FOREGROUND_OFFSET_X) 
                    | (command_buffer == CMD_SET_FOREGROUND_OFFSET_Y)
                    | (command_buffer == CMD_SET_FOREGROUND_CLIP_LEFT)
                    | (command_buffer == CMD_SET_FOREGROUND_CLIP_RIGHT)
                    | (command_buffer == CMD_SET_FOREGROUND_CLIP_TOP)
                    | (command_buffer == CMD_SET_FOREGROUND_CLIP_BOTTOM);

    wire spi_active;

    // Command processing
    always @ (posedge clk) begin
        if (~spi_active) begin
            command_state <= STATE_AWAITING_COMMAND;
        end 
        
        case (command_state)
            STATE_AWAITING_COMMAND: begin
                if (byte_ready) begin
                    command_buffer <= byte_out;

                    if (byte_out == CMD_START_IMAGE_UPLOAD) begin
                        command_state <= STATE_AWAITING_IMAGE;
                    end 
                    else
                    begin 
                        if (is_no_arg) begin
                            command_state <= STATE_AWAITING_PROCESSING;
                        end else begin
                            command_state <= STATE_AWAITING_DATA_1;
                        end
                    end
                end
            end
            STATE_AWAITING_DATA_1: begin
                if (byte_ready) begin
                    argument_buffer[7:0] <= byte_out;

                    if (is_one_arg) begin
                        command_state <= STATE_AWAITING_PROCESSING;
                    end else begin
                        command_state <= STATE_AWAITING_DATA_2;
                    end
                end
            end
            STATE_AWAITING_DATA_2: begin
                if (byte_ready) begin
                    argument_buffer <= {argument_buffer[7:0], byte_out};
                    command_state <= STATE_AWAITING_PROCESSING;
                end
            end
            STATE_AWAITING_PROCESSING: begin
                command_state <= process_command(command_buffer, argument_buffer);
            end
            STATE_AWAITING_IMAGE: begin
                // Do nothing
            end
            default: begin
                // No clue what is going on, just start over :)
                command_state <= STATE_AWAITING_COMMAND;
            end
        endcase
    end

    // Image upload handling
    pipeline_spi_image_receiver #(
        .PRECISION(PRECISION),
        .PIXEL_SIZE(PIXEL_SIZE),

        .RESOLUTION_X(RESOLUTION_X),
        .RESOLUTION_Y(RESOLUTION_Y)
    ) spi_image_receiver(
        .clk(clk),
        .enable_receive(command_state == STATE_AWAITING_IMAGE),

        .spi_byte_in(byte_out),
        .spi_byte_ready(byte_ready),

        .pixel_out(ctrl_image_pixel),
        .pixel_x(ctrl_image_pixel_x),
        .pixel_y(ctrl_image_pixel_y),
        .pixel_ready(ctrl_image_pixel_ready)
    );

    // SPI interface
    spi_slave spi_handle(
        .clk(clk),
        .hw_spi_clk(hw_spi_clk),
        .hw_spi_ss(hw_spi_ss),
        .hw_spi_mosi(hw_spi_mosi),
        .hw_spi_miso(hw_spi_miso),
        .spi_active(spi_active),
        .byte_out(byte_out),
        .byte_ready(byte_ready)
    );
endmodule
