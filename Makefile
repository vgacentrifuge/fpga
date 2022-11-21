ifeq ($(USE_DOCKER),)
USE_DOCKER=0 # Use "USE_DOCKER=1 make ..." instead
endif

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
CPP=include/lodepng/lodepng.cpp include/png_helper.cpp include/spi_helper.cpp include/control.cpp $(VERILATOR_FOLDER)/include/verilated.cpp $(wildcard obj_dir/*.cpp)
INC=-I$(VERILATOR_FOLDER)/include -I$(VERILATOR_FOLDER)/include/vltstd -Iinclude -Iinclude/lodepng -Iobj_dir

VERILATOR_INCLUDE_FOLDERS=$(sort $(dir $(SRC)))
VER_INC=$(patsubst %, -I%, $(VERILATOR_INCLUDE_FOLDERS))

%.cpp: %.v
	$(VERILATOR_EXEC) --cc $(VER_INC) $<

%.o: %.cpp
	g++ -std=c++11 $(INC) $(CPP) $< -o $@ 
	
.PHONY: lint format clean purge sim sim_chroma_key sim_full_delay sim_overlay_scale sim_spi sim_spi_control sim_spi_image

lint:
	verilator -Wall --lint-only $(VER_INC) $(SRC) --top-module top

setup:
	mkdir -p output

clean:
	rm -rf obj_dir test/*.o

purge: clean
	rm -rf output

sim: 
	make sim_chroma_key
	make sim_overlay_scale
	make sim_pipeline
	make sim_spi
	make sim_spi_control

pre_sim: clean setup

sim_spi: pre_sim src/spi/spi_slave.cpp test/sim_spi.o
	./test/sim_spi.o

sim_chroma_key: pre_sim src/pipeline/pipeline_mode_chroma_key.cpp test/sim_chroma_key.o
	./test/sim_chroma_key.o

sim_full_delay: pre_sim src/signal_full_delay.cpp test/sim_full_delay.o
	./test/sim_full_delay.o

sim_overlay_scale: pre_sim test/verilog/pipeline_foreground_scale_1080.cpp test/sim_overlay_scale.o
	./test/sim_overlay_scale.o 

sim_pipeline: pre_sim test/verilog/pipeline_1080.cpp test/sim_pipeline.o
	./test/sim_pipeline.o

sim_spi_control: pre_sim test/verilog/pipeline_spi_control_16b.cpp test/sim_spi_control.o
	./test/sim_spi_control.o

sim_spi_image: pre_sim test/verilog/pipeline_spi_control_16b.cpp test/sim_spi_image.o
	./test/sim_spi_image.o

format: $(SRC)
	for file in $^ ; do \
		$(JAVA_EXEC) -jar format/verilog-format.jar -f $$file -s format/verilog-format.properties ; \
	done
