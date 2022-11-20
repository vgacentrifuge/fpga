module pipeline_mode_chroma_key #(    
    parameter R_WIDTH = 5,
    parameter G_WIDTH = 6,
    parameter B_WIDTH = 5,
    
    localparam PIXEL_SIZE = R_WIDTH + G_WIDTH + B_WIDTH
) (
    input fg_pixel_ready,
    
    input [PIXEL_SIZE - 1:0] bg_pixel_in,
    input [PIXEL_SIZE - 1:0] fg_pixel_in,

    input [PIXEL_SIZE - 1:0] ctrl_green_screen_filter,

    output use_fg_pixel
);
    wire [R_WIDTH - 1:0] RED_PASS = ctrl_green_screen_filter[PIXEL_SIZE - 1:PIXEL_SIZE - R_WIDTH];
    wire [G_WIDTH - 1:0] GREEN_PASS = ctrl_green_screen_filter[PIXEL_SIZE - R_WIDTH - 1:PIXEL_SIZE - R_WIDTH - G_WIDTH];
    wire [B_WIDTH - 1:0] BLUE_PASS = ctrl_green_screen_filter[PIXEL_SIZE - R_WIDTH - G_WIDTH - 1:0];

    wire [R_WIDTH - 1:0] fg_red = fg_pixel_in[PIXEL_SIZE - 1:PIXEL_SIZE - R_WIDTH];
    wire [G_WIDTH - 1:0] fg_green = fg_pixel_in[PIXEL_SIZE - R_WIDTH - 1:PIXEL_SIZE - R_WIDTH - G_WIDTH];
    wire [B_WIDTH - 1:0] fg_blue = fg_pixel_in[PIXEL_SIZE - R_WIDTH - G_WIDTH - 1:0];

    wire is_green_screen = (fg_red <= RED_PASS) && (fg_green >= GREEN_PASS) && (fg_blue <= BLUE_PASS);
    
    assign use_fg_pixel = fg_pixel_ready & ~is_green_screen;
endmodule
