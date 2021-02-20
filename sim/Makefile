VERILOG_SOURCES = ../src/wrapper.v \
	../src/A5If.v \
	../src/Fifo.v \
	../src/A5LFSR.v \
	../src/A5Buffer.v \
	../src/A5Generator.v \
	testbench.v

GL_SOURCES = $(O)/macro/submission/results/lvs/wrapper.lvs.powered.v \
	testbench.v

COMPILE_ARGS=-D MPRJ_IO_PADS=38 -Wall -I sim

export COCOTB_RESULTS_FILE=$(O)/results.xml
export PYTHONDONTWRITEBYTECODE=1

.PHONY:	test_wrapper test_gl

test_wrapper:	$(VERILOG_SOURCES) test_wrapper.py
	iverilog -o $(O)/sim.vvp -s testbench -g2012 $(VERILOG_SOURCES) $(COMPILE_ARGS)
	MODULE=test_wrapper vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus $(O)/sim.vvp +vcd_filename=$(O)/wrapper.vcd

test_gl:	$(GL_SOURCES) test_wrapper.py
	iverilog -o $(O)/gl_sim.vvp -s testbench -g2012 $(GL_SOURCES) $(COMPILE_ARGS) -DGATE_LEVEL=1 -DFUNCTIONAL=1 -I $(PDK_ROOT)/sky130A/
	MODULE=test_wrapper vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus $(O)/gl_sim.vvp +vcd_filename=$(O)/wrapper.gl.vcd