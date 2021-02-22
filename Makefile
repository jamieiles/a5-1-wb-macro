O ?= $(PWD)

.PHONY:	harden sim formal
harden:	$(O)/macro/submission/results/magic/wrapper.gds

test_wrapper:
	$(MAKE) -C sim O=$(O) test_wrapper

test_gl:	$(O)/macro/submission/results/lvs/wrapper.lvs.powered.v
	$(MAKE) -C sim O=$(O) test_gl

formal:
	sby -f $(CURDIR)/sim/properties.sby -d $(O)/formal

$(O)/macro/submission/results/magic/wrapper.gds $(O)/macro/submission/results/lvs/wrapper.lvs.powered.v:	$(VERILOG_SOURCES) macro/config.tcl macro/wrapper.sdc
	docker run -it \
		-v $(CURDIR):/work \
		-v $(OPENLANE_ROOT):/openLANE_flow \
		-v $(PDK_ROOT):$(PDK_ROOT) \
		-v $(O):/out \
		-e PDK_ROOT=$(PDK_ROOT) \
		-u $(shell id -u $$USER):$(shell id -g $$USER) \
		openlane:rc6 \
		/bin/bash -c "./flow.tcl -overwrite -design /work/macro -run_path /out/macro -tag submission"
