/*
 * Single-channel transparency module. This module does not allow 100% transparency, since
 * that use is covered by display mode "none". 
 */
module transparency_colour_channel #(
    parameter TRANSPARENCY_PRECISION = 3,
    parameter CHANNEL_WIDTH = 6
) (
    input [CHANNEL_WIDTH - 1:0] src_a_in,
    input [CHANNEL_WIDTH - 1:0] src_b_in,

    // The amount of src_a we want. This value can not be set so high that we get none of src_b.
    input [TRANSPARENCY_PRECISION - 1:0] src_a_proportion, 
    
    output [CHANNEL_WIDTH - 1:0] channel_out
);
    wire [TRANSPARENCY_PRECISION:0] src_b_proportion = {1'b1, {TRANSPARENCY_PRECISION{1'b0}}} - {1'b0, src_a_proportion};
    wire [TRANSPARENCY_PRECISION + CHANNEL_WIDTH:0] weighted_sum = src_a_proportion * src_a_in + src_b_proportion * src_b_in;

    /*
    if 
        - CHANNEL_WIDTH = 8
        - TRANSPARENCY_PRECISION = 3
        - src_a_proportion = 50% = 2^3/2 = 4
        - src_a_in = src_b_in = 255
    
    then 
        - src_b_proportion = 0b1000 - 0b0100 = 0b100 = 4
        - weighted_sum = 4 * 255 + 4 * 255 = 2040
        - channel_out = 2040[10:3] ( = 2040 >> 3 = 2040 / 8) = 255
     */
    
    // This statement is equivalent to channel_out = weighted_sum >> TRANSPARENCY_PRECISION, which means
    // that our total expression is equivalent to:
    // channel_out 
    //  = (src_a_proportion * src_a_in + src_b_proportion * src_b_in) >> TRANSPARENCY_PRECISION
    //  = (src_a_proportion * src_a_in + src_b_proportion * src_b_in) / (src_a_proportion + src_b_proportion)
    assign channel_out = weighted_sum[TRANSPARENCY_PRECISION + CHANNEL_WIDTH - 1:TRANSPARENCY_PRECISION];
endmodule
