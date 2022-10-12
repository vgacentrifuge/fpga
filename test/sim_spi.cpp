#include <verilated.h>

#include <bitset>
#include <iostream>

#include "Vspi_slave.h"

const uint64_t CLK_PERIOD = 10;

Vspi_slave *top;

uint64_t main_time = 0;

double sc_time_stamp() { return main_time; }

void verify_byte(uint8_t byte) {
    /*
    input clk,
                     input spi_clk,
                     input spi_ss,
                     input spi_mosi,
                     output spi_miso,
                     output [7:0] byte_out,
                     output byte_ready
    */

    int8_t byte_pos = 7;
    uint64_t clock_index = 0;

    top->spi_clk = 0;
    top->clk = 0;
    top->spi_ss = 1;
    top->eval();

    while (clock_index <= (CLK_PERIOD * 16)) {
        top->clk = clock_index++ % 2;

        if (clock_index % CLK_PERIOD == 0) {
            top->spi_ss = 0;
            top->spi_clk = (clock_index / CLK_PERIOD) % 2;
            if (top->spi_clk) {
                top->spi_mosi = (byte >> byte_pos) & 1;
                std::cout << "Bit pos: " << (int) byte_pos << " MOSI: " << (int) top->spi_mosi << std::endl; 
                byte_pos--;
            }
        }

        top->eval();
    }

    if (top->byte_ready) {
        std::bitset<8> bits_read(top->byte_out);
        std::bitset<8> bits_expected(byte);
        std::cout << "Byte ready: " << (int)top->byte_out << " (Bits: "  << bits_read << ")" << std::endl;
        std::cout << "Expected byte: " << (int)byte << " (Bits: " << bits_expected << ")" << std::endl;
    } else {
        std::cout << "Byte not ready" << std::endl;
    }
}

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);

    top = new Vspi_slave;  // Create model

    verify_byte(0xAB);
    verify_byte(0xD2);
    verify_byte(0xFF);
    verify_byte(0x00);

    top->final();  // Done simulating
    delete top;
}