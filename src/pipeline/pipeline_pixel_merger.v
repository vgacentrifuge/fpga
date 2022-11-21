module pipeline_pixel_merger #(
    parameter TRANSPARENCY_PRECISION = 3,
    
    parameter R_WIDTH = 5,
    parameter G_WIDTH = 6,
    parameter B_WIDTH = 5,

    localparam PIXEL_SIZE = R_WIDTH + G_WIDTH + B_WIDTH
) (
    // Whether to use the foreground pixel or not. Should be set to 0
    // if there is no foreground pixel.
    input use_fg_pixel,
    
    input [PIXEL_SIZE - 1:0] bg_pixel_in,
    input [PIXEL_SIZE - 1:0] fg_pixel_in,

    input [TRANSPARENCY_PRECISION - 1:0] ctrl_fg_transparency,
    
    output [PIXEL_SIZE - 1:0] pixel_out
);
    wire [PIXEL_SIZE - 1:0] temp_output_pre_mask;
    assign pixel_out = use_fg_pixel ? temp_output_pre_mask : bg_pixel_in;
    
    localparam b_low_idx  = 0;
    localparam b_high_idx = b_low_idx + B_WIDTH - 1;
    localparam g_low_idx  = b_high_idx + 1;
    localparam g_high_idx = g_low_idx + G_WIDTH - 1;
    localparam r_low_idx  = g_high_idx + 1;
    localparam r_high_idx = r_low_idx + R_WIDTH - 1;

    /*
     * Use src_a = bg and src_b = fg, so that a src_a_proportion of 0 means
     * that the output is 100% foreground (100% opaque), which lets us use
     * ctrl_ctrl_fg_transparency directly.
     */
    
    transparency_colour_channel #(
        .CHANNEL_WIDTH(R_WIDTH),
        .TRANSPARENCY_PRECISION(TRANSPARENCY_PRECISION)
    ) r_channel(
        .src_a_in(bg_pixel_in[r_high_idx:r_low_idx]),
        .src_b_in(fg_pixel_in[r_high_idx:r_low_idx]),
        .channel_out(temp_output_pre_mask[r_high_idx:r_low_idx]),
        .src_a_proportion(ctrl_fg_transparency)
    );
    
    transparency_colour_channel #(
        .CHANNEL_WIDTH(G_WIDTH),
        .TRANSPARENCY_PRECISION(TRANSPARENCY_PRECISION)
    ) g_channel(
        .src_a_in(bg_pixel_in[g_high_idx:g_low_idx]),
        .src_b_in(fg_pixel_in[g_high_idx:g_low_idx]),
        .channel_out(temp_output_pre_mask[g_high_idx:g_low_idx]),
        .src_a_proportion(ctrl_fg_transparency)
    );
    
    transparency_colour_channel #(
        .CHANNEL_WIDTH(B_WIDTH),
        .TRANSPARENCY_PRECISION(TRANSPARENCY_PRECISION)
    ) b_channel(
        .src_a_in(bg_pixel_in[b_high_idx:b_low_idx]),
        .src_b_in(fg_pixel_in[b_high_idx:b_low_idx]),
        .channel_out(temp_output_pre_mask[b_high_idx:b_low_idx]),
        .src_a_proportion(ctrl_fg_transparency)
    );
endmodule
