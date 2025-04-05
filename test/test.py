# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

# Test values  decimal / binary to decimal
# "0110000"; -- 1 / 48
# "1101101"; -- 2 / 109
# "1111001"; -- 3 / 121
# "0110011"; -- 4 / 51
# "1011011"; -- 5 / 91
# "1011111"; -- 6 / 95
# "1110000"; -- 7 / 112
# "1111111"; -- 8 / 127
# "1111011"; -- 9 / 123
# others / 

@cocotb.test()
async def test_project_d6(dut):
    dut._log.info("Start testing d6")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0  # Stop the counter
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    dut._log.info("Test project behavior")

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)
    dut.rst_n.value = 0
    assert dut.uo_out.value[1:7].integer == 48, f"{dut.uo_out.value = }"  # Our default reset value

    dut.ui_in.value = 1  # Start the counter
    await ClockCycles(dut.clk, 5)

    assert dut.uo_out.value[1:7].integer == 91, f"{dut.uo_out.value = }"

    # Wait 6 more cycles and expect the same result
    await ClockCycles(dut.clk, 6)
    assert dut.uo_out.value[1:7].integer == 91, f"{dut.uo_out.value = }"

    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value[1:7].integer == 95, f"{dut.uo_out.value = }"

    # Simulate stopping the timer
    dut.ui_in.value = 0

    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value[1:7].integer == 48, f"{dut.uo_out.value = }"
    await ClockCycles(dut.clk, 3)
    assert dut.uo_out.value[1:7].integer == 48, f"{dut.uo_out.value = }"


    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.

@cocotb.test()
async def test_project_d4(dut):

    dut._log.info("Start testing d4")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0  # Stop the counter
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    dut._log.info("Test project behavior")

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)
    dut.rst_n.value = 0
    
    assert dut.uo_out.value[1:7].integer == 48, f"{dut.uo_out.value = }"  # Our default reset value

    # Press the d4 selection
    dut.ui_in.value = 0b00000010
    
    # Wait for 10 cycles to pulse one time
    await ClockCycles(dut.clk, 10)
    
    # Turn off the d4 mode and start the counter
    dut.ui_in.value = 0b00000001
    await ClockCycles(dut.clk, 2)

    # After 1 cycle from default, should result in a 2
    assert dut.uo_out.value[1:7].integer == 109, f"{dut.uo_out.value = }"  # Our default reset value

    # Overflow 4 cycles and result in a 2
    await ClockCycles(dut.clk, 4)
    assert dut.uo_out.value[1:7].integer == 109, f"{dut.uo_out.value = }"  # Our default reset value

    # Overflow 5 cycles and result in a 3
    await ClockCycles(dut.clk, 5)
    assert dut.uo_out.value[1:7].integer == 121, f"{dut.uo_out.value = }"  # Our default reset value



@cocotb.test()
async def test_project_d8(dut):

    dut._log.info("Start testing d8")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0  # Stop the counter
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    dut._log.info("Test project behavior")

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)
    dut.rst_n.value = 0
    
    assert dut.uo_out.value[1:7].integer == 48, f"{dut.uo_out.value = }"  # Our default reset value

    # Press the dice selection for a d4
    dut.ui_in.value = 0b00000010
    # Wait for 2 cycles to pulse one time
    await ClockCycles(dut.clk, 2)
    
    # Turn off the d4 mode and start the counter
    dut.ui_in.value = 0b00000000
    await ClockCycles(dut.clk, 2)

    # Press the dice selection from d4 to d8
    dut.ui_in.value = 0b00000010
    # Wait for 2 cycles to pulse one time
    await ClockCycles(dut.clk, 2)
    
    # Turn off the dice mode and start the counter
    dut.ui_in.value = 0b00000001
    await ClockCycles(dut.clk, 2)

    # After 1 cycle from default, should result in a 2
    assert dut.uo_out.value[1:7].integer == 109, f"{dut.uo_out.value = }"  # Our default reset value

    # Overflow 8 cycles and result in a 2
    await ClockCycles(dut.clk, 8)
    assert dut.uo_out.value[1:7].integer == 109, f"{dut.uo_out.value = }"  # Our default reset value

    # 5 more cycles should result in a 7
    await ClockCycles(dut.clk, 5)
    assert dut.uo_out.value[1:7].integer == 112, f"{dut.uo_out.value = }"  # Our default reset value



