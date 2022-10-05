module sim(input clk,
           input reset,
           output reg [31:0] value);
    counter counter_1 (.clk (clk),
    .reset (reset),
    .double (1'b0),
    .value (value));
endmodule
