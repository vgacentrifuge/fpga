module pipeline_chroma_key #(
    parameter RED_PASS = 5'b00100,
    parameter GREEN_PASS = 6'b101100,
    parameter BLUE_PASS = 5'b01100,
    parameter PIXEL_SIZE = 16,
    parameter RED_SIZE = 5,
    parameter GREEN_SIZE = 6
) (
    input enable,
    input [PIXEL_SIZE - 1:0] bg_pixel_in,
    input [PIXEL_SIZE - 1:0] fg_pixel_in,
    output reg [PIXEL_SIZE - 1:0] pixel_out
);
    
    wire [4:0] fg_red = fg_pixel_in[PIXEL_SIZE - 1:PIXEL_SIZE - RED_SIZE];
    wire [5:0] fg_green = fg_pixel_in[PIXEL_SIZE - RED_SIZE - 1:PIXEL_SIZE - RED_SIZE - GREEN_SIZE];
    wire [4:0] fg_blue = fg_pixel_in[PIXEL_SIZE - RED_SIZE - GREEN_SIZE - 1:0];

    wire is_green_screen = (fg_red <= RED_PASS) && (fg_green >= GREEN_PASS) && (fg_blue <= BLUE_PASS);
    
    assign pixel_out = (~enable || is_green_screen) ? bg_pixel_in : fg_pixel_in;
endmodule
