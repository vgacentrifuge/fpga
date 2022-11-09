#include "verilated_vcd_c.h"
#include <verilated.h>
#include <iostream>
#include "Vsignal_full_delay.h"

Vsignal_full_delay *signal_full_delay;

uint64_t main_time = 0;

double sc_time_stamp()
{
  return main_time;
}

int main(int argc, char **argv)
{
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC;
  signal_full_delay = new Vsignal_full_delay; // Create model

  signal_full_delay->trace(tfp, 10);
  tfp->open("signal_full_delay.vcd");

  signal_full_delay->signal_in = 0;
  signal_full_delay->eval();

  while (main_time < 500)
  {
    if (main_time % 10 == 1)
    {
      signal_full_delay->clk = 1; // Toggle clock
    }
    if (main_time % 10 == 6)
    {
      signal_full_delay->clk = 0;
    }

    // on 11th clock cycle insert signal_in
    if (main_time >100 && main_time <=110)
    {
      signal_full_delay->signal_in = 1;
    } else {
      signal_full_delay->signal_in = 0;
    }
    if (main_time == 101) { std::cout << "First 1 through" << std::endl;}

    signal_full_delay->eval();              // Evaluate model
    tfp->dump(main_time);
    if (main_time % 10 == 1) {
    std::cout << (int)signal_full_delay->signal_out; // Read a output
}
    main_time++;              // Time passes...
  }

  signal_full_delay->final(); // Done simulating
  tfp->close();
  delete signal_full_delay;
  std::cout << std::endl;
}
