SRC=$(wildcard src/*.v) $(wildcard src/*/*.v)
VERILATOR_FOLDER=$(shell verilator --getenv VERILATOR_ROOT)
CPP=include/lodepng/lodepng.cpp include/png_helper.cpp $(VERILATOR_FOLDER)/include/verilated.cpp $(wildcard obj_dir/*.cpp)
INC=-I$(VERILATOR_FOLDER)/include -I$(VERILATOR_FOLDER)/include/vltstd -Iinclude -Iinclude/lodepng -Iobj_dir

%.cpp: %.v
	verilator --cc $<

%.o: %.cpp
	g++ -std=c++11 $(INC) $(CPP) $< -o $@ 
	
.PHONY: format clean sim_chroma_key sim_full_delay sim_overlay_scale

clean:
	rm -rf obj_dir test/*.o *.png

sim_chroma_key: clean src/pipeline/pipeline_chroma_key.cpp test/sim_chroma_key.o
	./test/sim_chroma_key.o

sim_full_delay: clean src/signal_full_delay.cpp test/sim_full_delay.o
	./test/sim_full_delay.o

sim_overlay_scale: clean src/pipeline/pipeline_foreground_overlay.cpp src/pipeline/pipeline_foreground_scale_1080.cpp test/sim_overlay_scale.o
	./test/sim_overlay_scale.o 

format: $(SRC)
	for file in $^ ; do \
		java -jar format/verilog-format.jar -f $$file -s format/verilog-format.properties ; \
	done