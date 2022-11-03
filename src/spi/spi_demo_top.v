//`include "src/spi/spi_slave.v"

module spi_demo_top(input clk,
                    input hw_spi_clk,
                    input hw_spi_ss,
                    input hw_spi_mosi,
                    output hw_spi_miso,
                    output [7:0] led);
    wire [7:0] byte_out;
    wire byte_ready;
    
    spi_slave spi(
    .clk(clk),
    .hw_spi_clk(hw_spi_clk),
    .hw_spi_ss(hw_spi_ss),
    .hw_spi_mosi(hw_spi_mosi),
    .hw_spi_miso(hw_spi_miso),
    .byte_out(byte_out),
    .byte_ready(byte_ready)
    );
    
    reg [7:0] led_reg;
    
    always @(posedge clk) begin
        if (byte_ready) led_reg <= byte_out;
    end
    
    assign led = led_reg;
endmodule
