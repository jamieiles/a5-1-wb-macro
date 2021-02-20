`timescale 1ns/1ns
`ifdef GATE_LEVEL
`define UNIT_DELAY #1
`define USE_POWER_PINS
`include "libs.ref/sky130_fd_sc_hd/verilog/primitives.v"
`include "libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v"
`endif
module testbench (
    input wire wb_clk_i,
    input wire wb_rst_i,
    input wire wbs_stb_i,
    input wire wbs_cyc_i,
    input wire wbs_we_i,
    input wire [3:0] wbs_sel_i,
    input wire [31:0] wbs_dat_i,
    input wire [31:0] wbs_adr_i,
    output wire wbs_ack_o,
    output wire [31:0] wbs_dat_o,
    input  wire [31:0] la_data_in,
    output wire [31:0] la_data_out,
    input  wire [31:0] la_oen,
    input  wire [`MPRJ_IO_PADS-1:0] io_in,
    output wire [`MPRJ_IO_PADS-1:0] io_out,
    output wire [`MPRJ_IO_PADS-1:0] io_oeb,
    input wire active
);

wrapper wrapper(
`ifdef GATE_LEVEL
    .VPWR(1'b1),
    .VGND(1'b0),
`endif /* GATE_LEVEL */
    .wb_clk_i(wb_clk_i),
    .wb_rst_i(wb_rst_i),
    .wbs_stb_i(wbs_stb_i),
    .wbs_cyc_i(wbs_cyc_i),
    .wbs_we_i(wbs_we_i),
    .wbs_sel_i(wbs_sel_i),
    .wbs_dat_i(wbs_dat_i),
    .wbs_adr_i(wbs_adr_i),
    .wbs_ack_o(wbs_ack_o),
    .wbs_dat_o(wbs_dat_o),
    .la_data_in(la_data_in),
    .la_data_out(la_data_out),
    .la_oen(la_oen),
    .io_in(io_in),
    .io_out(io_out),
    .io_oeb(io_oeb),
    .active(active)
);

reg [8 * 4096:0] vcd_filename;

initial begin
    if (! $value$plusargs("vcd_filename=%s", vcd_filename)) begin
        $display("ERROR: please specify +vcd_filename=<value> as an absolute path.");
        $finish;
    end
    $dumpfile(vcd_filename);
    $dumpvars(0, wrapper);
end

endmodule
