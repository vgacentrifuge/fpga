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

  signal_full_delay = new Vsim; // Create model

  signal_full_delay->reset = 0; // Set some inputs
  signal_full_delay->signal_in = 0;

  while (!Verilated::gotFinish())
  {
    if ((main_time % 10) == 1)
    {
      signal_full_delay->clk = 1; // Toggle clock
    }
    if ((main_time % 10) == 6)
    {
      signal_full_delay->clk = 0;
    }

    if (main_time == 10)
    {
      signal_full_delay->signal_in = 1;
    } else 
      signal_full_delay->signal_in = 0;
    }

    signal_full_delay->eval();              // Evaluate model
    std::cout << signal_full_delay->signal_out << std::endl; // Read a output
    main_time++;              // Time passes...
  }

  signal_full_delay->final(); // Done simulating
  delete signal_full_delay;
}
