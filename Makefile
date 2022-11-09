SRC=$(wildcard src/*.v) $(wildcard src/*/*.v)
veril:=docker run -ti -v ${PWD}\:/work --user $(id -u)\:$(id -g) verilator/verilator\:latest
#veril:="verilator"

.PHONY: format build_sim run_sim build_full_delay_sim

format: $(SRC)
	for file in $^ ; do \
		java -jar format/verilog-format.jar -f $$file -s format/verilog-format.properties ; \
	done

build_sim:
	$(veril) -Wall --cc --exe --build test/sim_main.cpp src/sim.v

run_sim:
	./obj_dir/Vsim

build_full_delay_sim:
	$(veril) -Wall --cc --exe --trace --build test/sim_full_delay.cpp src/signal_full_delay.v
	./obj_dir/Vsignal_full_delay
