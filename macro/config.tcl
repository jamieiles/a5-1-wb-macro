set ::env(DESIGN_NAME) "wrapper"
set ::env(VERILOG_FILES) "$::env(DESIGN_DIR)/../A5If.v
    $::env(DESIGN_DIR)/../A5LFSR.v
    $::env(DESIGN_DIR)/../A5Generator.v
    $::env(DESIGN_DIR)/../wrapper.v
    $::env(DESIGN_DIR)/../Fifo.v"
set ::env(SDC_FILE) "$::env(DESIGN_DIR)/wrapper.sdc"

set ::env(DIE_AREA) "0 0 300 300"
set ::env(FP_SIZING) absolute
set ::env(DESIGN_IS_CORE) 0
set ::env(GLB_RT_MAXLAYER) 5

set ::env(CLOCK_PERIOD) "10.000"
set ::env(CLOCK_PORT) "wb_clk_i"
