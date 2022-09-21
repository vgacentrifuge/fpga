SRC=$(wildcard *.v)

format: $(SRC)
	for file in $^ ; do \
		java -jar format/verilog-format.jar -f $$file -s format/verilog-format.properties ; \
	done

build_sim:
	verilator -Wall --cc --exe --build sim_main.cpp sim.v

run_sim:
	./obj_dir/Vsim