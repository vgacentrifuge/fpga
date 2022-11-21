#include "spi_helper.h"

void start_transmission(SPISlave &slave) {
    *slave.hw_spi_clk = 0;
    *slave.clk = 0;
    *slave.hw_spi_ss = 0;
    slave.eval();

    *slave.clk = 1;
    slave.eval();
}

void end_transmission(SPISlave &slave) {
    *slave.hw_spi_clk = 0;
    *slave.clk = 0;
    *slave.hw_spi_ss = 1;
    slave.eval();

    // This has to run for a few cycles because the SPI slave
    // has a bias towards remaining active.
    for (int i = 1; i < 40; i++) {
        *slave.clk = i % 2;
        slave.eval();
    }
}

void write_byte(SPISlave &slave, uint8_t byte) {
    int8_t byte_pos = 7;
    uint64_t clock_index = 0;

    while (clock_index <= (CLK_PERIOD * 16 + 8)) {
        *slave.clk = ++clock_index % 2;

        if (clock_index % CLK_PERIOD == 0) {
            *slave.hw_spi_clk = (clock_index / CLK_PERIOD) % 2;

            if (*slave.hw_spi_clk) {
                *slave.hw_spi_mosi = (byte >> byte_pos) & 1;
                byte_pos--;
            }
        }

        slave.eval();
    }
}