USE_DOCKER=0 # Use "USE_DOCKER=1 make ..." instead

ifeq ($(USE_DOCKER), 1)
	VERILATOR_EXEC=docker run -ti --rm -v ${PWD}\:/work --user $(shell id -u)\:$(shell id -g) verilator/verilator\:latest
	JAVA_EXEC=docker run -ti --rm -v ${PWD}/src\:/src -v ${PWD}/format\:/format --user $(shell id -u)\:$(shell id -g) eclipse-temurin:19-alpine java
	VERILATOR_FOLDER=obj_dir/vlt
else
	VERILATOR_EXEC=verilator
	JAVA_EXEC=java
	VERILATOR_FOLDER=$(shell verilator --getenv VERILATOR_ROOT)
endif

SRC=$(wildcard src/*.v) $(wildcard src/*/*.v)
CPP=include/lodepng/lodepng.cpp include/png_helper.cpp $(VERILATOR_FOLDER)/include/verilated.cpp $(wildcard obj_dir/*.cpp)
INC=-I$(VERILATOR_FOLDER)/include -I$(VERILATOR_FOLDER)/include/vltstd -Iinclude -Iinclude/lodepng -Iobj_dir

VERILATOR_INCLUDE_FOLDERS=$(sort $(dir $(SRC)))
VER_INC=$(patsubst %, -I%, $(VERILATOR_INCLUDE_FOLDERS))

%.cpp: %.v
	$(VERILATOR_EXEC) --cc $(VER_INC) $<

%.o: %.cpp
	g++ -std=c++11 $(INC) $(CPP) $< -o $@ 
	
.PHONY: format clean purge sim_chroma_key sim_full_delay sim_overlay_scale

clean:
	rm -rf obj_dir test/*.o

purge: clean
	rm -rf output

outdir:
	mkdir -p output

sim_chroma_key: clean src/pipeline/pipeline_chroma_key.cpp test/sim_chroma_key.o outdir
	./test/sim_chroma_key.o

sim_full_delay: clean src/signal_full_delay.cpp test/sim_full_delay.o outdir
	./test/sim_full_delay.o

sim_overlay_scale: clean src/pipeline/pipeline_foreground_overlay.cpp src/pipeline/pipeline_foreground_scale_1080.cpp test/sim_overlay_scale.o outdir
	./test/sim_overlay_scale.o 

sim_pipeline: clean src/pipeline/pipeline.cpp test/sim_pipeline.o outdir
	./test/sim_pipeline.o

format: $(SRC)
	for file in $^ ; do \
		$(JAVA_EXEC) -jar format/verilog-format.jar -f $$file -s format/verilog-format.properties ; \
	done
