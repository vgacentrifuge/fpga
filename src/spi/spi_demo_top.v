//`include "src/spi/spi_slave.v"

module spi_demo_top(
    input clk,
    input spi_clk,
    input spi_ss,
    input spi_mosi,
    output spi_miso,
    output [7:0] led
);
    wire [7:0] byte_out;
    wire byte_ready;

    spi_slave spi(
        .clk(clk),
        .spi_clk(spi_clk),
        .spi_ss(spi_ss),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        .byte_out(byte_out),
        .byte_ready(byte_ready)
    );
    
    reg [7:0] led_reg;

    always @(posedge clk) begin
        if (byte_ready) led_reg <= byte_out;
    end

    assign led = led_reg;
endmodule