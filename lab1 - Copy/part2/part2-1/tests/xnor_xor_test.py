import cocotb
from cocotb.triggers import Timer

import os
from pathlib import Path
from cocotb_tools.runner import get_runner

@cocotb.test()
async def test_xnor_xor(dut):
    """Test all input combinations for xnor_xor module"""
    
    test_cases = [
        (0, 0, 0, 1),  # (0 XNOR 0) XOR 0 = 1 XOR 0 = 1
        (0, 0, 1, 0),  # (0 XNOR 0) XOR 1 = 1 XOR 1 = 0
        (0, 1, 0, 0),  # (0 XNOR 1) XOR 0 = 0 XOR 0 = 0
        (0, 1, 1, 1),  # (0 XNOR 1) XOR 1 = 0 XOR 1 = 1
        (1, 0, 0, 0),  # (1 XNOR 0) XOR 0 = 0 XOR 0 = 0
        (1, 0, 1, 1),  # (1 XNOR 0) XOR 1 = 0 XOR 1 = 1
        (1, 1, 0, 1),  # (1 XNOR 1) XOR 0 = 1 XOR 0 = 1
        (1, 1, 1, 0),  # (1 XNOR 1) XOR 1 = 1 XOR 1 = 0
    ]
    
    for in1, in2, in3, expected in test_cases:
        dut.in1.value = in1
        dut.in2.value = in2
        dut.in3.value = in3
        
        await Timer(1, unit="ns")
        
        actual = dut.out.value
        status = "PASS" if actual == expected else "FAIL"
        
        assert actual == expected, f"Mismatch: got {actual}, expected {expected}"

def runner():
    # --- Fill the information below ---
    
    # Path to all related Verilog files
    verilog_files = [
        "../xnor_xor.v"
    ]
    
    # Top-level module name
    top_module = "xnor_xor"
    
    # Test module name (normally it is the name of this file without .py
    # except your testcase is in other Python file)
    test_module = "xnor_xor_test"
    
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