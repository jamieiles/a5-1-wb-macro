# SPDX-FileCopyrightText: 2020 Efabless Corporation, 2021 Jamie Iles
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

CARAVEL_PATH ?= $(CARAVEL_ROOT)
CARAVEL_DV_PATH := $(CARAVEL_PATH)/verilog/dv/caravel/
O ?= $(shell pwd)

FIRMWARE_PATH := $(CARAVEL_DV_PATH)
VERILOG_PATH := $(CARAVEL_PATH)/verilog
RTL_PATH := $(VERILOG_PATH)/rtl
GL_PATH := $(VERILOG_PATH)/gl
BEHAVIOURAL_MODELS := $(CARAVEL_DV_PATH)

## User Project Pointers
UPRJ_VERILOG_PATH ?= $(CARAVEL_PATH)/../verilog
UPRJ_RTL_PATH = $(UPRJ_VERILOG_PATH)/rtl
UPRJ_BEHAVIOURAL_MODELS = ../

GCC_PATH ?= /ef/apps/bin
GCC_PREFIX ?= riscv32-unknown-elf
PDK_PATH ?= /ef/tech/SW/sky130A

SRC_PATH ?= $(CARAVEL_PATH)/../verilog/rtl/a5-1-wb-macro/src/

GL_A51 ?= ../../../verilog/rtl/a5-1-wb-macro/gds/wrapped_a51.lvs.powered.v

SIM ?= RTL

.SUFFIXES:

PATTERN = a5

all:  $(O)/${PATTERN:=.$(SIM).fst}

hex:  $(O)/${PATTERN:=.hex}

$(O)/%.vvp: %_tb.v $(O)/%.hex
ifeq ($(SIM),RTL)
	iverilog -DFUNCTIONAL -DSIM -I $(BEHAVIOURAL_MODELS) \
	-I $(PDK_PATH) -DUSE_POWER_PINS=1 -I $(RTL_PATH) -I $(UPRJ_RTL_PATH) -DFIRMWARE_FILE=\"$(O)/a5.hex\" \
	$< -o $@
else
	iverilog -DFUNCTIONAL -DSIM -DGL -I $(BEHAVIOURAL_MODELS) \
	-I $(PDK_PATH) -I $(VERILOG_PATH) -I $(RTL_PATH) -I $(VERILOG_PATH) -I$(UPRJ_VERILOG_PATH) -I $(UPRJ_RTL_PATH) -I $(CARAVEL_PATH)/../../../verilog -DFIRMWARE_FILE=\"$(O)/a5.hex\" \
	$< $(GL_A51) -o $@
endif

$(O)/%.$(SIM).fst: $(O)/%.vvp
	vvp $< -fst +fst_filename=$(O)/caravel.$(SIM).fst +firmware=$(O)/a5.hex

$(O)/%.elf: %.c $(FIRMWARE_PATH)/sections.lds $(FIRMWARE_PATH)/start.s
	${GCC_PATH}/${GCC_PREFIX}-gcc -Wall -Wextra -I$(FIRMWARE_PATH) -march=rv32imc -mabi=ilp32 -Wl,-Bstatic,-T,$(FIRMWARE_PATH)/sections.lds,--strip-debug -ffreestanding -nostdlib -o $@ $(FIRMWARE_PATH)/start.s $<

$(O)/%.hex: $(O)/%.elf
	@echo "O=$(O)"
	${GCC_PATH}/${GCC_PREFIX}-objcopy -O verilog $< $@
	# to fix flash base address
	sed -i 's/@10000000/@00000000/g' $@

$(O)/%.bin: $(O)/%.elf
	${GCC_PATH}/${GCC_PREFIX}-objcopy -O binary $< /dev/stdout | tail -c +1048577 > $@

# ---- Clean ----

clean:
	rm -f $(O)/*.elf $(O)/*.hex $(O)/*.bin $(O)/*.vvp $(O)/*.fst $(O)/*.log

.PHONY: clean hex all
