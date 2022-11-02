module pipeline_chroma_key(
    input clk,
    input enable,
    input [15:0] bg_pixel_in,
    input [15:0] fg_pixel_in,
    output [15:0] pixel_out,
);
    parameter GREEN_PASS = 6'b010000;

    wire fg_green = fg_pixel_in[11:5];

    assign pixel_out = (~enable || fg_green >= GREEN_PASS) ? bg_pixel_in : fg_pixel_in;
endmodule