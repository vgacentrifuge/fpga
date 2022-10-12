#include <verilated.h>
#include <iostream>
#include "Vsim.h"

Vsim *top;

uint64_t main_time = 0;

double sc_time_stamp()
{
  return main_time;
}

int main(int argc, char **argv)
{
  Verilated::commandArgs(argc, argv);

  top = new Vsim; // Create model

  top->reset = 0; // Set some inputs

  while (!Verilated::gotFinish())
  {
    if ((main_time % 10) == 1)
    {
      top->clk = 1; // Toggle clock
    }
    if ((main_time % 10) == 6)
    {
      top->clk = 0;
    }

    top->eval();              // Evaluate model
    std::cout << top->value << std::endl; // Read a output
    main_time++;              // Time passes...
  }

  top->final(); // Done simulating
  delete top;
}