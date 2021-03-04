O ?= $(PWD)

VERILOG_SOURCES = src/wrapper.v \
	src/A5If.v \
	src/Fifo.v \
	src/A5LFSR.v \
	src/A5Buffer.v \
	src/A5Generator.v \
	sim/testbench.v \
	sim/defines.v \
	macro/defines.v

.PHONY:	harden sim formal test_caravel
harden:	$(O)/macro/submission/results/magic/wrapped_a51.gds

test_wrapper:
	$(MAKE) -C sim O=$(O) test_wrapper

test_gl:	$(O)/macro/submission/results/lvs/wrapped_a51.lvs.powered.v
	$(MAKE) -C sim O=$(O) test_gl

test_caravel:
	$(MAKE) -C caravel_test SRC_PATH=$(PWD)/src O=$(O)

test_caravel_gl:
	$(MAKE) -C caravel_test SRC_PATH=$(PWD)/src O=$(O)

formal:
	sby -f $(CURDIR)/sim/properties.sby -d $(O)/formal

$(O)/macro/submission/results/magic/wrapped_a51.gds $(O)/macro/submission/results/lvs/wrapped_a51.lvs.powered.v:	$(VERILOG_SOURCES) macro/config.tcl macro/wrapper.sdc
	docker run -it \
		-v $(CURDIR):/work \
		-v $(OPENLANE_ROOT):/openLANE_flow \
		-v $(PDK_ROOT):$(PDK_ROOT) \
		-v $(O):/out \
		-e PDK_ROOT=$(PDK_ROOT) \
		-u $(shell id -u $$USER):$(shell id -g $$USER) \
		openlane:rc6 \
		/bin/bash -c "./flow.tcl -overwrite -design /work/macro -run_path /out/macro -tag submission"
