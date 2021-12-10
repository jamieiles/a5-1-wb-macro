set script_dir [file dirname [file normalize [info script]]]
set ::env(DESIGN_NAME) "wrapped_a51"
set ::env(VERILOG_FILES) "$::env(DESIGN_DIR)/defines.v
    $::env(DESIGN_DIR)/../src/A5If.v
    $::env(DESIGN_DIR)/../src/A5LFSR.v
    $::env(DESIGN_DIR)/../src/A5Buffer.v
    $::env(DESIGN_DIR)/../src/A5Generator.v
    $::env(DESIGN_DIR)/../src/wrapper.v
    $::env(DESIGN_DIR)/../src/Fifo.v"
set ::env(SDC_FILE) "$::env(DESIGN_DIR)/wrapper.sdc"
set ::env(VERILOG_INCLUDE_DIRS) "$::env(DESIGN_DIR)"

set ::env(DIE_AREA) "0 0 380 380"
set ::env(FP_SIZING) absolute
set ::env(DESIGN_IS_CORE) 0
set ::env(GLB_RT_MAXLAYER) 5

set ::env(CLOCK_PERIOD) "7.500"
set ::env(CLOCK_PORT) "wb_clk_i"

set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]
set ::env(FP_PIN_ORDER_CFG) "$::env(DESIGN_DIR)/pin_order.cfg"
set ::env(RUN_CVC) 0

set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0

# fix for hold time violation
set ::env(PL_RESIZER_HOLD_SLACK_MARGIN) 0.5
set ::env(GLB_RESIZER_HOLD_SLACK_MARGIN) 0.5

set ::env(FP_IO_VTHICKNESS_MULT) 4
set ::env(FP_IO_HTHICKNESS_MULT) 4
