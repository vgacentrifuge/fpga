`include "counter.v"

module top(
    input clk,
    output wire [7:0] LED
);
    reg [31:0] counter_val;
    wire reset;

    counter led_counter (
        .clk(clk),
        .reset(reset),
        .double(1'b0),
        .value(counter_val)
    );

    assign reset = counter_val[31];
    assign LED = counter_val[30:23];
endmodule