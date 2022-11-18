module transparency_colour_channel #(
    parameter TRANSPARENCY_PRECISION,
    parameter CHANNEL_WIDTH
) (
    input [CHANNEL_WIDTH-1:0] src_a_in,
    input [CHANNEL_WIDTH-1:0] src_b_in,
    // This should be between 0 and 2^TRANSPARENCY_PRECISION
    input [TRANSPARENCY_PRECISION:0] src_a_proportion,
    output [CHANNEL_WIDTH-1:0] channel_out
);
  wire [TRANSPARENCY_PRECISION:0] src_b_proportion           = {1'b1, {TRANSPARENCY_PRECISION{1'b0}}} - src_a_proportion;
  wire [TRANSPARENCY_PRECISION + CHANNEL_WIDTH:0] weighted_sum = src_a_proportion * src_a_in + src_b_proportion * src_b_in;
  /*
    if 
        - CHANNEL_WIDTH = 8
        - TRANSPARENCY_PRECISION = 4
        - src_a_proportion = 50% = 2^4/2 = 8
        - src_a_in = src_b_in = 255
    
    then 
        - src_b_proportion = 0b10000 - 0b1000 = 0b1111 = 8
        - weighted_sum = 8 * 255 + 8 * 255 = 4080
        - channel_out = 4080[11:4] ( = 4080 >> 4 = 4080 / 16) = 255
     */

  // This statement is equivalent to channel_out = weighted_sum >> TRANSPARENCY_PRECISION, which means
  // that our total expression is equivalent to:
  // channel_out 
  //  = (src_a_proportion * src_a_in + src_b_proportion * src_b_in) >> TRANSPARENCY_PRECISION
  //  = (src_a_proportion * src_a_in + src_b_proportion * src_b_in) / (src_a_proportion + src_b_proportion)
  assign channel_out = weighted_sum[TRANSPARENCY_PRECISION+CHANNEL_WIDTH-1:TRANSPARENCY_PRECISION];
endmodule
