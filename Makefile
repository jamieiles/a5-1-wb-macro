VERILOG_SOURCES = $(PWD)/wrapper.v $(PWD)/testbench.v $(PWD)/A5If.v $(PWD)/Fifo.v
TOPLEVEL=testbench
MODULE=test_wrapper
COMPILE_ARGS=-D MPRJ_IO_PADS=38 -Wall
SIM_BUILD=$(PWD)/_build/sim_build
export PYTHONDONTWRITEBYTECODE=1

include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY:	harden
harden:	_build/macro/submission/results/magic/wrapper.gds

_build/macro/submission/results/magic/wrapper.gds:	$(VERILOG_SOURCES) $(PWD)/macro/config.tcl $(PWD)/macro/wrapper.sdc
	@docker run -it \
		-v $(PWD):/work \
		-v $(OPENLANE_ROOT):/openLANE_flow \
		-v $(PDK_ROOT):$(PDK_ROOT) \
		-e PDK_ROOT=$(PDK_ROOT) \
		-u $(shell id -u $$USER):$(shell id -g $$USER) \
		openlane:rc6 \
		/bin/bash -c "./flow.tcl -overwrite -design /work/macro -run_path /work/_build/macro -tag submission"