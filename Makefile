SRC=$(wildcard src/*.v) $(wildcard src/*/*.v)

%.cpp: %.v
	verilator --cc $<
	
.PHONY: format build_sim run_sim

format: $(SRC)
	for file in $^ ; do \
		java -jar format/verilog-format.jar -f $$file -s format/verilog-format.properties ; \
	done

build_sim:
	verilator -Wall --cc --exe --build test/sim_main.cpp src/sim.v

run_sim:
	./obj_dir/Vsim

build_full_delay_sim:
	verilator --cc --exe --build -Wall test/sim_full_delay.cpp src/signal_full_delay.v
