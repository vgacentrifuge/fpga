#ifndef SPI_HELPER_H
#define SPI_HELPER_H

#include <stdint.h>

#define CLK_PERIOD 1000

struct SPISlave {
    void (*eval)();
    uint8_t *clk;
    uint8_t *hw_spi_clk;
    uint8_t *hw_spi_ss;
    uint8_t *hw_spi_mosi;
};

void start_transmission(SPISlave &slave);

void end_transmission(SPISlave &slave);

void write_byte(SPISlave &slave, uint8_t byte);

#endif