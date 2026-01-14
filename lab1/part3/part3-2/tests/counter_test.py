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
    enable = (0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0)
    reset = (0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0)
   
    for i in range(12):
        dut.enable.value = enable[i]
        dut.reset.value = reset[i]
        await RisingEdge(dut.clk)
    
    
    

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