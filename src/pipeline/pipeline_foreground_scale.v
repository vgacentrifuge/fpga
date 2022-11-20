module pipeline_foreground_scale #(
    parameter RESOLUTION_X = 800,
    parameter RESOLUTION_Y = 600,
    parameter PRECISION = 11
) (
    input clk,
    input output_enable, 
    input [1:0] ctrl_foreground_scale,
    input signed [PRECISION:0] fg_offset_x,
    input signed [PRECISION:0] fg_offset_y,
    input [PRECISION - 1:0] pixel_x,
    input [PRECISION - 1:0] pixel_y,
    
    output reg signed [PRECISION:0] fg_pixel_x,
    output reg signed [PRECISION:0] fg_pixel_y,
    output reg fg_active
);
    localparam SCALE_FULL = 2'b00;
    localparam SCALE_HALF = 2'b01;
    localparam SCALE_QUARTER = 2'b10;
    
    wire signed [PRECISION:0] offset_x = pixel_x - fg_offset_x;
    wire signed [PRECISION:0] offset_y = pixel_y - fg_offset_y;

    wire above_zero = (offset_x >= 0) && (offset_y >= 0);

    wire exceeds_x = (fg_pixel_x >= RESOLUTION_X) || (fg_pixel_x < 0);
    wire exceeds_y = (fg_pixel_y >= RESOLUTION_Y) || (fg_pixel_y < 0);

    always @ (posedge clk)
    begin
        fg_active <= 1'b0;
        
        if (output_enable) begin
            case (ctrl_foreground_scale)
                SCALE_FULL: begin
                    fg_pixel_x <= offset_x;
                    fg_pixel_y <= offset_y;
                    fg_active  <= 1'b1;
                end
                SCALE_HALF: begin    
                    if (offset_x <= RESOLUTION_X / 2 && offset_y <= RESOLUTION_Y / 2 && above_zero) begin
                        fg_pixel_x <= offset_x << 1;
                        fg_pixel_y <= offset_y << 1;
                        fg_active <= 1'b1;
                    end
                end
                SCALE_QUARTER: begin
                    if (offset_x <= RESOLUTION_X / 4 && offset_y <= RESOLUTION_Y / 4 && above_zero) begin
                        fg_pixel_x <= offset_x << 2;
                        fg_pixel_y <= offset_y << 2;
                        fg_active <= 1'b1;
                    end
                end
                default: begin
                    fg_pixel_x <= 0;
                    fg_pixel_y <= 0;
                end
            endcase
        end
    end
endmodule
