`include "src/counter.v"

module sim(input clk,
           input reset,
           output reg [31:0] value);
    counter counter_1 (.clk (clk),
    .reset (reset),
    .value (value));
endmodule
