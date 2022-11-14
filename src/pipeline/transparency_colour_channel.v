module transparency_colour_channel #(parameter TRANSPARENCY_PRECISION,
                                     parameter CHANNEL_WIDTH)
                                    (input [CHANNEL_WIDTH-1:0] src_a_in,
                                     input [CHANNEL_WIDTH-1:0] src_b_in,
                                     input [TRANSPARENCY_PRECISION-1:0] src_a_proportion), // This should be between 0 and 2^TRANSPARENCY_PRECISION-1
                                     output [CHANNEL_WIDTH-1:0] channel_out;
    wire [TRANSPARENCY_PRECISION-1:0] src_b_proportion           = {TRANSPARENCY_PRECISION{1'b1}}-src_a_proportion;
    wire [TRANSPARENCY_PRECISION+CHANNEL_WIDTH-1:0] weighted_sum = src_a_proportion*src_a_in+src_b_proportion*src_b_in;
    /*
     if channel width = 8, precision = 4, proportion = 50% = 8, and a = b = 255
     then weighted_sum = 4080, channel out = 255
     */
    
    assign channel_out = weighted_sum[TRANSPARENCY_PRECISION+CHANNEL_WIDTH-1:TRANSPARENCY_PRECISION];
    // This will implicitly divide the weighted sum by 2^precision to get only the CHANNEL_WIDTH MSBs
    // The weighted sum is something like (a*p+b*(2^TRANSPARENCY_PRECISION-p))/(a+b), if p is a [0,TRANSPARENCY_PRECISION[ value
    // Since a+b==2^TRANSPARENCY_PRECISION, we can srl instead.
endmodule
