from enum import Enum
from functools import partial

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles

from cocotbext.wishbone.driver import WishboneMaster
from cocotbext.wishbone.driver import WBOp


class Register(Enum):
    ID = 0x00
    STATUS = 0x04
    CONTROL = 0x08
    DATA = 0x0c
    KEY_LO = 0x10
    KEY_HI = 0x14
    FRAME = 0x18


REFERENCE_KEYSTREAM = [
    0x1a5572ca,
    0x58a817f4,
    0x5aa1876d,
    0xfc90314e,
    0xeaeb16b2,
    0x32d929b7,
    0x63ed827d,
    0x3fd5e4fd,
]
REFERENCE_KEY = 0xefcdab8967452312
REFERENCE_FRAME = 0x134


class A5Testbench(object):
    def __init__(self, dut):
        self._add_reg_accessors()
        self.dut = dut
        clock = Clock(self.dut.wb_clk_i, 10, units="ns")
        cocotb.fork(clock.start())

        self.wbs = WishboneMaster(dut, "wbs", dut.wb_clk_i,
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

    def _add_reg_accessors(self):
        for reg in Register:
            setattr(self.__class__, 'read_{0}'.format(reg.name.lower()),
                    partial(self._read_reg, reg.value))
            setattr(self.__class__, 'write_{0}'.format(reg.name.lower()),
                    partial(self._write_reg, reg.value))

    async def reset(self):
        # Activate user design
        self.dut.active <= 1
        # Chip level reset
        self.dut.wb_rst_i <= 1
        await ClockCycles(self.dut.wb_clk_i, 1)
        self.dut.wb_rst_i <= 0
        # Reset design
        self.dut.la_data_in <= 0
        await ClockCycles(self.dut.wb_clk_i, 1)
        self.dut.la_data_in <= 1
        await ClockCycles(self.dut.wb_clk_i, 1)

    async def _read_reg(self, reg):
        wbRes = await self.wbs.send_cycle([WBOp(reg)])
        return wbRes[0].datrd.integer

    async def _write_reg(self, reg, val):
        await self.wbs.send_cycle([WBOp(reg, val)])

    async def wait_not_empty(self):
        while await self.read_status() & 0x1 == 0:
            continue

    async def generate(self, key, frame):
        await self.write_key_hi((key >> 32) & 0xffffffff)
        await self.write_key_lo(key & 0xffffffff)
        await self.write_frame(frame)
        await self.write_control(0x1)


@cocotb.test()
async def test_id_reg(dut):
    a5 = A5Testbench(dut)
    await a5.reset()
    assert await a5.read_id() == 0x41354135


@cocotb.test()
async def test_reference_keystream(dut):
    a5 = A5Testbench(dut)
    await a5.reset()

    keystream = []
    await a5.generate(REFERENCE_KEY, REFERENCE_FRAME)
    for _ in range(8):
        await a5.wait_not_empty()
        keystream.append(await a5.read_data())
    assert keystream == REFERENCE_KEYSTREAM


@cocotb.test()
async def test_new_key_flushes(dut):
    a5 = A5Testbench(dut)
    await a5.reset()

    await a5.generate(REFERENCE_KEY, REFERENCE_FRAME)
    await a5.wait_not_empty()
    await a5.generate(0, 0)
    assert await a5.read_status() & 1 == 0
    keystream = []
    for _ in range(8):
        await a5.wait_not_empty()
        keystream.append(await a5.read_data())
    assert keystream != REFERENCE_KEYSTREAM


@cocotb.test()
async def test_key_readback(dut):
    a5 = A5Testbench(dut)
    await a5.reset()

    await a5.generate(REFERENCE_KEY, REFERENCE_FRAME)
    await a5.wait_not_empty()
    assert await a5.read_key_hi() == 0xefcdab89
    assert await a5.read_key_lo() == 0x67452312
    assert await a5.read_frame() == 0x134
