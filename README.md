# FPGA

Code written in Verilog

## Helpful commands

Format code with
```bash
make format
```

## Simulation

Requires [Verilator](https://www.veripool.org/verilator/)

Run & build simulation with
```bash
make <target>
```

Available simulation targets:
 - sim_chroma_key 
 - sim_full_delay
 - sim_overlay_scale
 - sim_spi
 - sim_spi_control
 
## Clean up any generate files with
```bash
make purge
```
