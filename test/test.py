# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    dut.ui_in.value = 1
    dut.uio_in.value = 2

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)
    dut.rst_n.value = 0

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    #assert dut.uo_out.value == 50
    # Test values  decimal / binary to decimal
    # "0110000"; -- 1 / 48
    # "1101101"; -- 2 / 109
    # "1111001"; -- 3 / 121
    # "0110011"; -- 4 / 51
    # "1011011"; -- 5 / 91
    # "1011111"; -- 6 / 95
    # "1111111"; -- others / 127

    await ClockCycles(dut.clk, 5)
    assert dut.uo_out.value[1:7].integer == 91, f"{dut.uo_out.value = }"

    # Wait 6 more cycles and expect the same result
    await ClockCycles(dut.clk, 6)
    assert dut.uo_out.value[1:7].integer == 91, f"{dut.uo_out.value = }"

    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value[1:7].integer == 95, f"{dut.uo_out.value = }"
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value[1:7].integer == 48, f"{dut.uo_out.value = }"
    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
