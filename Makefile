SRC=$(wildcard *.v)

format: $(SRC)
	java -jar format/verilog-format.jar -f $^ -s format/verilog-format.properties