`include "counter.v"

module top(
    input clk,
    output [7:0] LED
);
    wire [31:0] counter_val;
    wire reset;

    counter led_counter (
        .clk(clk),
        .reset(reset),
        .double(1'b0),
        .value(counter_val)
    );

    assign LED = counter_val[30:23];
    assign reset = counter_val[31];
endmodule