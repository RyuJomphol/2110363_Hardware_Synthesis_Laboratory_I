import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge, FallingEdge

import os
from pathlib import Path
from cocotb_tools.runner import get_runner

@cocotb.test()
async def jkff_test_1(dut):
    j = (0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1)
    k = (1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    q = (None, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1)
    clock = Clock(dut.clk, 10, unit="ns")
    clock.start(start_high=False)
    
    for i in range(0, len(j), 2):
        dut.J.value = j[i]
        dut.K.value = k[i]
        await Timer(1, unit='ns')
        if q[i] is not None:    # Check waveform at falling edge
            assert dut.Q.value == q[i], f"[Assertion {i}] Expected q to be {q[i]}, but got {dut.Q.value}"
        await RisingEdge(dut.clk)
        if i+1 >= len(j):
            break
        dut.J.value = j[i+1]
        dut.K.value = k[i+1]
        await Timer(1, unit='ns')
        if q[i+1] is not None:  # Check waveform at rising edge
            assert dut.Q.value == q[i+1], f"[Assertion {i+1}] Expected q to be {q[i+1]}, but got {dut.Q.value}"
        await FallingEdge(dut.clk)

@cocotb.test()
async def jkff_test_2(dut):
    j = (0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1)
    k = (1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0)
    q = (None, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1)
    clock = Clock(dut.clk, 10, unit="ns")
    clock.start(start_high=False)
    
    for i in range(0, len(j), 2):
        dut.J.value = j[i]
        dut.K.value = k[i]
        await Timer(1, unit='ns')
        if q[i] is not None:    # Check waveform at falling edge
            assert dut.Q.value == q[i], f"[Assertion {i}] Expected q to be {q[i]}, but got {dut.Q.value}"
        await RisingEdge(dut.clk)
        if i+1 >= len(j):
            break
        dut.J.value = j[i+1]
        dut.K.value = k[i+1]
        await Timer(1, unit='ns')
        if q[i+1] is not None:  # Check waveform at rising edge
            assert dut.Q.value == q[i+1], f"[Assertion {i+1}] Expected q to be {q[i+1]}, but got {dut.Q.value}"
        await FallingEdge(dut.clk)
        
def runner():
    # --- Fill the information below ---
    
    # Path to all related Verilog files
    verilog_files = [
        "../jkff.v"
    ]
    
    # Top-level module name
    top_module = "jkff"
    
    # Test module name (normally it is the name of this file without .py
    # except your testcase is in other Python file)
    test_module = "jkff_test"
    
    # ----------------------------------
    
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent

    sources = [proj_path / Path(f) for f in verilog_files]
    
    runner = get_runner(sim)

    runner.build(
        sources=sources,
        hdl_toplevel=top_module,
        always=True,
        waves=True,
        timescale=('1ns','1ps')
    )
    
    runner.test(hdl_toplevel=top_module, test_module=test_module, waves=True)

if __name__ == "__main__":
    runner()