module mcu_spi(input clk,
               input spi_clk,
               input spi_ss,
               input spi_mosi,
               output spi_miso,
) spi_slave spi_handler(.clk(clk), .spi_clk(spi_clk), .spi_ss(spi_ss), .spi_mosi(spi_mosi), .spi_miso(spi_miso), .byte_out(byte_out), .byte_ready(byte_ready));
    
endmodule
