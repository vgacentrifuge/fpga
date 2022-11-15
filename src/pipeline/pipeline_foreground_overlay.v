module pipeline_foreground_overlay #(
    parameter PIXEL_SIZE = 16
) (
    input enable,
    input [PIXEL_SIZE - 1:0] bg_pixel_in,
    input [PIXEL_SIZE - 1:0] fg_pixel_in,
    output [PIXEL_SIZE - 1:0] pixel_out
);
    assign pixel_out = enable ? fg_pixel_in : bg_pixel_in;
endmodule
