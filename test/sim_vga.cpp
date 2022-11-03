#include <verilated.h>

#include <bitset>
#include <iostream>

#include "Vvgademo_top.h"

const uint64_t CLK_PERIOD = 1000;

Vvgademo_top *top;

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);

    top = new Vvgademo_top;  // Create model

    top->final();  // Done simulating
    delete top;
}