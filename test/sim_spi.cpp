#include <verilated.h>

#include <bitset>
#include <iostream>

#include "Vspi_slave.h"

const uint64_t CLK_PERIOD = 1000;

Vspi_slave *top;

uint64_t main_time = 0;

double sc_time_stamp() { return main_time; }

void verify_byte(uint8_t byte) {
    int8_t byte_pos = 7;
    uint64_t clock_index = 0;

    top->hw_spi_clk = 0;
    top->clk = 0;
    top->hw_spi_ss = 1;
    top->eval();

    uint8_t byte_in = 0;
    bool ready = false;

    while (clock_index <= (CLK_PERIOD * 16 + 8)) {
        top->clk = ++clock_index % 2;

        if (clock_index % CLK_PERIOD == 0) {
            top->hw_spi_ss = 0;
            top->hw_spi_clk = (clock_index / CLK_PERIOD) % 2;

            if (top->hw_spi_clk) {
                top->hw_spi_mosi = (byte >> byte_pos) & 1;
                std::cout << "Bit pos: " << (int)byte_pos
                          << " MOSI: " << (int)top->hw_spi_mosi << std::endl;
                byte_pos--;
            }
        }

        top->eval();

        if (top->byte_ready && top->clk) {
            if (ready) {
                std::cout << "ERROR: byte_ready was asserted twice"
                          << std::endl;
                exit(1);
            }

            ready = true;
            byte_in = top->byte_out;
        }
    }

    std::bitset<8> bits_expected(byte);
    std::cout << "Expected byte: " << (int)byte << " (Bits: " << bits_expected
              << ")" << std::endl;

    if (ready) {
        std::bitset<8> bits_read(byte_in);
        std::cout << "Byte ready: " << (int)byte_in << " (Bits: " << bits_read
                  << ")" << std::endl;

        if (byte_in != byte) {
            std::cout << "ERROR: byte read does not match expected byte"
                      << std::endl;
            exit(1);
        }
    } else {
        std::cout << "Byte not ready" << std::endl;
        exit(1);
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