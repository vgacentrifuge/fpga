SRC=$(wildcard src/*.v) $(wildcard src/*/*.v)
CPP=include/lodepng/lodepng.cpp include/png_helper.cpp /opt/homebrew/Cellar/verilator/4.228/share/verilator/include/verilated.cpp $(wildcard obj_dir/*.cpp)
INC=-I/opt/homebrew/Cellar/verilator/4.228/share/verilator/include -I/opt/homebrew/Cellar/verilator/4.228/share/verilator/include/vltstd -Iinclude -Iinclude/lodepng -Iobj_dir

%.cpp: %.v
	verilator --cc $<

%.o: %.cpp
	g++ -std=c++11 $(INC) $(CPP) $< -o $@ 
	
.PHONY: format clean sim_chroma_key

clean:
	rm -rf obj_dir test/*.o output.png

sim_chroma_key: clean src/pipeline/pipeline_chroma_key.cpp test/sim_chroma_key.o
	./test/sim_chroma_key.o

sim_full_delay: clean src/signal_full_delay.cpp test/sim_full_delay.o
	./test/sim_full_delay.o

format: $(SRC)
	for file in $^ ; do \
		java -jar format/verilog-format.jar -f $$file -s format/verilog-format.properties ; \
	done