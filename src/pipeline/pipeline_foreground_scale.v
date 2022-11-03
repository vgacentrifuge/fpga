module pipeline_foreground_scale(input clk,
                                 input [1:0] ctrl_foreground_scale,
                                 input [9:0] fg_offset_x,
                                 input [9:0] fg_offset_y,
                                 input [9:0] pixel_x,
                                 input [9:0] pixel_y,
                                 output reg [9:0] fg_pixel_x,
                                 output reg [9:0] fg_pixel_y,
                                 output reg fg_active);
    parameter RESOLUTION_X = 640;
    parameter RESOLUTION_Y = 480;
    
    wire scale_full    = ctrl_foreground_scale == 2'b11;
    wire scale_half    = ctrl_foreground_scale == 2'b10;
    wire scale_quarter = ctrl_foreground_scale == 2'b01;
    
    // TODO: Offset
    
    always @ (posedge clk)
    begin
        fg_active <= 1'b0;
        
        if (scale_full)
        begin
            fg_pixel_x <= pixel_x;
            fg_pixel_y <= pixel_y;
            fg_active  <= 1'b1;
        end
        else if (scale_half)
        begin
            if (pixel_x >= RESOLUTION_X / 2 && pixel_y >= RESOLUTION_Y / 2)
            begin
                fg_pixel_x <= (pixel_x - RESOLUTION_X / 2) << 1;
                fg_pixel_y <= (pixel_y - RESOLUTION_Y / 2) << 1;
                fg_active  <= 1'b1;
            end
            else
                fg_active <= 1'b0;
        end
        else if (scale_quarter)
        begin
            if (pixel_x >= RESOLUTION_X / 4 && pixel_y >= RESOLUTION_Y / 4)
            begin
                fg_pixel_x <= (pixel_x - RESOLUTION_X / 4) << 2;
                fg_pixel_y <= (pixel_y - RESOLUTION_Y / 4) << 2;
                fg_active  <= 1'b1;
            end
            else
                fg_active <= 1'b0;
        end
    end
endmodule
