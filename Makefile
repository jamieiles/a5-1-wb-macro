O ?= $(PWD)

VERILOG_SOURCES = wrapper.v \
	testbench.v \
	A5If.v \
	Fifo.v \
	A5LFSR.v \
	A5Buffer.v \
	A5Generator.v

TOPLEVEL=testbench
MODULE=test_wrapper
COMPILE_ARGS=-D MPRJ_IO_PADS=38 -Wall -I sim
SIM_BUILD=$(O)/sim_build
PLUSARGS=+vcd_filename=$(O)/wrapper.vcd

export COCOTB_RESULTS_FILE=$(O)/results.xml
export PYTHONDONTWRITEBYTECODE=1

include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY:	harden
harden:	$(O)/macro/submission/results/magic/wrapper.gds

$(O)/macro/submission/results/magic/wrapper.gds:	$(VERILOG_SOURCES) macro/config.tcl macro/wrapper.sdc
	docker run -it \
		-v $(CURDIR):/work \
		-v $(OPENLANE_ROOT):/openLANE_flow \
		-v $(PDK_ROOT):$(PDK_ROOT) \
		-v $(O):/out \
		-e PDK_ROOT=$(PDK_ROOT) \
		-u $(shell id -u $$USER):$(shell id -g $$USER) \
		openlane:rc6 \
		/bin/bash -c "./flow.tcl -overwrite -design /work/macro -run_path /out/macro -tag submission"
