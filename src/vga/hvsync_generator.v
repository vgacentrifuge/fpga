module hvsync_generator(input clk,
                        input [10:0] pixel_position_x,
                        input [10:0] pixel_position_y,

                        output hw_vga_h_sync,
    
                        output hw_vga_v_sync,
                        
                        output in_display_area);
    parameter X_RES = 800;
    parameter Y_RES = 600;
    
    parameter H_SYNC = 128;
    parameter V_SYNC = 4;
    
    parameter H_FRONT_PORCH = 40;
    parameter V_FRONT_PORCH = 1;
    //parameter H_BACK_PORCH  = 48;
    //parameter V_BACK_PORCH  = 33;
    
    assign in_display_area = (pixel_position_x < X_RES) && (pixel_position_y < Y_RES);
    
    assign hw_vga_h_sync = ((pixel_position_x >= (X_RES + H_FRONT_PORCH) && (pixel_position_x < (X_RES + H_SYNC + H_FRONT_PORCH))));
    assign hw_vga_v_sync = ((pixel_position_y >= (Y_RES + V_FRONT_PORCH) && (pixel_position_y < (Y_RES + V_SYNC + V_FRONT_PORCH))));
endmodule
