import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge, FallingEdge
import logging

import os
from pathlib import Path
from cocotb_tools.runner import get_runner

@cocotb.test()
async def counter_test(dut):
    # Create a logger for this testbench
    logger = logging.getLogger("counter_test")
    logger.info("Starting Counter Testbench")
    clock = Clock(dut.clk, 10, units="ns")
    clock.start(start_high=True)
    
    #  TODO: Fill your testbench code here
    # Initialize inputs
    dut.reset.value = 0
    dut.enable.value = 0

    # Synchronize with the clock start
    await RisingEdge(dut.clk)

    # ------------------------------------------------
    # Cycle 0: Enable=0, Reset=0 -> Output 0
    # ------------------------------------------------
    dut.enable.value = 0
    dut.reset.value = 0
    await FallingEdge(dut.clk)
    assert dut.count.value == 0

    # ------------------------------------------------
    # Cycle 1: Enable=0, Reset=0 -> Output 0
    # ------------------------------------------------
    dut.enable.value = 0
    dut.reset.value = 0
    await FallingEdge(dut.clk)
    assert dut.count.value == 0

    # ------------------------------------------------
    # Cycle 2: Enable=0, Reset=1 -> Output 0 (Reset Active)
    # ------------------------------------------------
    dut.enable.value = 0
    dut.reset.value = 1
    await FallingEdge(dut.clk)
    assert dut.count.value == 0

    # ------------------------------------------------
    # Cycle 3: Enable=0, Reset=0 -> Output 0 (Hold 0)
    # ------------------------------------------------
    dut.enable.value = 0
    dut.reset.value = 0
    await FallingEdge(dut.clk)
    assert dut.count.value == 0

    # ------------------------------------------------
    # Cycle 4: Enable=1, Reset=0 -> Output 1 (Count 0->1)
    # ------------------------------------------------
    dut.enable.value = 1
    dut.reset.value = 0
    await FallingEdge(dut.clk)
    assert dut.count.value == 1

    # ------------------------------------------------
    # Cycle 5: Enable=1, Reset=0 -> Output 2 (Count 1->2)
    # ------------------------------------------------
    dut.enable.value = 1
    dut.reset.value = 0
    await FallingEdge(dut.clk)
    assert dut.count.value == 2

    # ------------------------------------------------
    # Cycle 6: Enable=0, Reset=0 -> Output 2 (Hold at 2)
    # ------------------------------------------------
    dut.enable.value = 0
    dut.reset.value = 0
    await FallingEdge(dut.clk)
    assert dut.count.value == 2

    # ------------------------------------------------
    # Cycle 7: Enable=1, Reset=0 -> Output 3 (Count 2->3)
    # ------------------------------------------------
    dut.enable.value = 1
    dut.reset.value = 0
    await FallingEdge(dut.clk)
    assert dut.count.value == 3

    # ------------------------------------------------
    # Cycle 8: Enable=1, Reset=0 -> Output 4 (Count 3->4)
    # ------------------------------------------------
    dut.enable.value = 1
    dut.reset.value = 0
    await FallingEdge(dut.clk)
    assert dut.count.value == 4

    # ------------------------------------------------
    # Cycle 9: Enable=1, Reset=0 -> Output 5 (Count 4->5)
    # ------------------------------------------------
    dut.enable.value = 1
    dut.reset.value = 0
    await FallingEdge(dut.clk)
    assert dut.count.value == 5

    # ------------------------------------------------
    # Cycle 10: Enable=0, Reset=0 -> Output 5 (Hold at 5)
    # ------------------------------------------------
    dut.enable.value = 0
    dut.reset.value = 0
    await FallingEdge(dut.clk)
    assert dut.count.value == 5

    # ------------------------------------------------
    # Cycle 11: Enable=0, Reset=0 -> Output 5 (Hold at 5)
    # ------------------------------------------------
    dut.enable.value = 0
    dut.reset.value = 0
    await FallingEdge(dut.clk)
    assert dut.count.value == 5
    
    
    

def runner():
    # --- Fill the information below ---
    
    # Path to all related Verilog files
    verilog_files = [
        "../counter.v"
    ]
    
    # Top-level module name
    top_module = "counter"
    
    # Test module name (normally it is the name of this file without .py
    # except your testcase is in other Python file)
    test_module = "counter_test"
    
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