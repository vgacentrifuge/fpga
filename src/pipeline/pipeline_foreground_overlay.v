module pipeline_foreground_overlay(input clk,
                                   input enable,
                                   input [15:0] bg_pixel_in,
                                   input [15:0] fg_pixel_in,
                                   output [15:0] pixel_out,
                                   );
    assign pixel_out = enable ? fg_pixel_in : bg_pixel_in;
endmodule
