VERILOG_SOURCES = ../src/wrapper.v \
	../src/A5If.v \
	../src/Fifo.v \
	../src/A5LFSR.v \
	../src/A5Buffer.v \
	../src/A5Generator.v \
	testbench.v

TOPLEVEL=testbench
MODULE=test_wrapper
COMPILE_ARGS=-D MPRJ_IO_PADS=38 -Wall -I sim
SIM_BUILD=$(O)/sim_build
PLUSARGS=+vcd_filename=$(O)/wrapper.vcd

export COCOTB_RESULTS_FILE=$(O)/results.xml
export PYTHONDONTWRITEBYTECODE=1

include $(shell cocotb-config --makefiles)/Makefile.sim