/*
 * Sample module for showing how the simulator can be used. See test/sim_main.cpp
 */

`include "src/counter.v"

module sim(input clk,
           input reset,
           output reg [31:0] value);
    counter counter_1 (.clk (clk),
    .reset (reset),
    .value (value));
endmodule
