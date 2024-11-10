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

    # Set the input values you want to test //a1
    dut.ui_in.value = 40
    dut.uio_in.value = 20

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 2)
    assert dut.uio_out.value == 3
    assert dut.uo_out.value == 32

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values
