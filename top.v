`include "counter.v"

module top(
    input clk,
    output reg [7:0] LED
);
    reg [31:0] counter_val;
    wire reset;

    counter led_counter (
        .clk(clk),
        .reset(reset),
        .double(1'b0),
        .value(counter_val)
    );

    always @(posedge clk) begin
        if (counter_val == 32'd100000000) begin
            reset <= 1'b1;
        end else begin
            reset <= 1'b0;
        end
    end

    assign LED = counter_val[7:0];
endmodule