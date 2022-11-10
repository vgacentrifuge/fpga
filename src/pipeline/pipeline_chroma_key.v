module pipeline_chroma_key(
                           input enable,
                           input [15:0] bg_pixel_in,
                           input [15:0] fg_pixel_in,
                           output reg [15:0] pixel_out);
    parameter RED_PASS = 5'b00100;
    parameter GREEN_PASS = 6'b101100;
    parameter BLUE_PASS = 5'b01100;
    
    wire [4:0] fg_red = fg_pixel_in[15:11];
    wire [5:0] fg_green = fg_pixel_in[10:5];
    wire [4:0] fg_blue = fg_pixel_in[4:0];

    wire is_green_screen = (fg_red <= RED_PASS) && (fg_green >= GREEN_PASS) && (fg_blue <= BLUE_PASS);
    
    assign pixel_out = (~enable || is_green_screen) ? bg_pixel_in : fg_pixel_in;
endmodule
