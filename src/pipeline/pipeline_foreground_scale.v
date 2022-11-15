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
    output fg_active
);
    
    wire scale_full    = ctrl_foreground_scale == 2'b11;
    wire scale_half    = ctrl_foreground_scale == 2'b10;
    wire scale_quarter = ctrl_foreground_scale == 2'b01;
    
    wire signed [PRECISION:0] offset_x = pixel_x + fg_offset_x;
    wire signed [PRECISION:0] offset_y = pixel_y + fg_offset_y;

    wire exceeds_x = (fg_pixel_x >= RESOLUTION_X) || (fg_pixel_x < 0);
    wire exceeds_y = (fg_pixel_y >= RESOLUTION_Y) || (fg_pixel_y < 0);

    reg active;

    assign fg_active = active && !exceeds_x && !exceeds_y;

    always @ (posedge clk)
    begin
        active <= 1'b0;
        
        if (output_enable) begin
            if (scale_full)
            begin
                fg_pixel_x <= offset_x;
                fg_pixel_y <= offset_y;
                active  <= 1'b1;
            end
            else if (scale_half)
            begin
                if (offset_x >= RESOLUTION_X / 2 && offset_y >= RESOLUTION_Y / 2)
                begin
                    fg_pixel_x <= (offset_x - RESOLUTION_X / 2 + 1) << 1;
                    fg_pixel_y <= (offset_y - RESOLUTION_Y / 2 + 1) << 1;
                    active  <= 1'b1;
                end
                else
                    active <= 1'b0;
            end
            else if (scale_quarter)
            begin
                if (offset_x >= 3 * (RESOLUTION_X / 4) && offset_y >= 3 * (RESOLUTION_Y / 4))
                begin
                    fg_pixel_x <= (offset_x - 3 * RESOLUTION_X / 4 + 1) << 2;
                    fg_pixel_y <= (offset_y - 3 * RESOLUTION_Y / 4 + 1) << 2;
                    active  <= 1'b1;
                end
                else
                    active <= 1'b0;
            end
        end
    end
endmodule
