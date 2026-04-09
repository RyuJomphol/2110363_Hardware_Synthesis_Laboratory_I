import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotbext.axi import AxiStreamBus, AxiStreamSource, AxiStreamSink, AxiStreamMonitor
import random

import os
from pathlib import Path
from cocotb_tools.runner import get_runner
from cocotb.clock import Clock


@cocotb.test()
async def test_data_generator_reset(dut):
    """Test data generator reset."""
    # Initialize clock
    clock = Clock(dut.s_axis_aclk, 10, unit="ns")
    clock.start()
    dut.testcase_id.value = 0  # Set testcase_id to 0 for reset test

    # Reset the DUT
    dut.s_axis_rst.value = 1
    dut.s_axis_tvalid.value = 0
    dut.s_axis_tdata.value = 0
    await RisingEdge(dut.s_axis_aclk)
    await Timer(10, unit="ns")
    dut.s_axis_rst.value = 0
    # check initial state during reset
    assert dut.s_axis_tready.value == 0, "s_axis_ready should be low during reset"
    assert dut.m_axis_tvalid.value == 0, "m_axis_tvalid should be low during reset"

    await Timer(100, unit="ns")

def generate_data(length):
    """Helper function to generate data based on length."""
    return bytes([i % 256 for i in range(length)])

@cocotb.test()
async def test_data_generator_full(dut):
    """Test data generator data generation"""
    # Initialize clock
    clock = Clock(dut.s_axis_aclk, 10, unit="ns")
    clock.start()

    # Init AXI Stream interfaces
    axis_source = AxiStreamSource(
        AxiStreamBus.from_prefix(dut, "s_axis"), dut.s_axis_aclk, dut.s_axis_rst
    )
    axis_sink = AxiStreamSink(
        AxiStreamBus.from_prefix(dut, "m_axis"), dut.s_axis_aclk, dut.s_axis_rst
    )

    # Reset the DUT
    dut.s_axis_rst.value = 1
    dut.s_axis_tvalid.value = 0
    dut.s_axis_tdata.value = 0
    await RisingEdge(dut.s_axis_aclk)
    await Timer(10, unit="ns")
    dut.s_axis_rst.value = 0
    await Timer(100, unit="ns")

    for i in range(256):
        dut.testcase_id.value = i  # Set testcase_id to current iteration
        await axis_source.send(bytes([i]))  # Send data of length i

        data = await axis_sink.recv()  # Receive data from DUT
        expected_data = generate_data(i)  # Generate expected data
        assert data.tdata == expected_data, f"Data mismatch for length {i}: expected {expected_data.hex()}, got {data.tdata.hex()}"

    # clean up
    await Timer(100, unit="ns")
    


def runner():
    sim = os.getenv("SIM", "icarus")

    sources = [Path("data_generator.v")]

    top_module = "data_generator"
    test_module = "tb"

    runner = get_runner(sim)

    runner.build(
        sources=sources,
        hdl_toplevel=top_module,
        always=True,
        waves=True,
        timescale=("1ns", "1ps"),
    )

    runner.test(
        hdl_toplevel=top_module,
        test_module=test_module,
        waves=True,
    )


if __name__ == "__main__":
    runner()
