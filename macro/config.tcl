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

set ::env(DIE_AREA) "0 0 300 300"
set ::env(FP_SIZING) absolute
set ::env(DESIGN_IS_CORE) 0
set ::env(GLB_RT_MAXLAYER) 5

set ::env(CLOCK_PERIOD) "7.500"
set ::env(CLOCK_PORT) "wb_clk_i"
