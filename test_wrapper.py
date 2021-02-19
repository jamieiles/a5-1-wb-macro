import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles

from cocotbext.wishbone.driver import WishboneMaster
from cocotbext.wishbone.driver import WBOp


@cocotb.test()
async def test_wrapper(dut):
    clock = Clock(dut.wb_clk_i, 10, units="ns")
    cocotb.fork(clock.start())

    wbs = WishboneMaster(dut, "wbs", dut.wb_clk_i,
                         timeout=10,  # in clock cycle number
                         signals_dict={
                             "cyc":  "cyc_i",
                             "stb":  "stb_i",
                             "we":   "we_i",
                             "adr":  "adr_i",
                             "datwr": "dat_i",
                             "datrd": "dat_o",
                             "ack":  "ack_o",
                             "sel":  "sel_i"}
                         )

    dut.active <= 1
    dut.wb_rst_i <= 1
    await ClockCycles(dut.wb_clk_i, 5)
    dut.wb_rst_i <= 0
    dut.la_data_in <= 0
    await ClockCycles(dut.wb_clk_i, 5)
    dut.la_data_in <= 1
    await ClockCycles(dut.wb_clk_i, 128)

    wbRes = await wbs.send_cycle([WBOp(0x10, 0x12345678), WBOp(0x14, 0xdefaced0), WBOp(0x18, 0), WBOp(4)])
    await ClockCycles(dut.wb_clk_i, 128)

    for _ in range(8):
        wbRes = await wbs.send_cycle([WBOp(0)])
        print(['{0:08x}'.format(w.datrd.integer) for w in wbRes])
        await ClockCycles(dut.wb_clk_i, 128)
