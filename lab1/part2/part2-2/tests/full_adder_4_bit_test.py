import cocotb
from cocotb.triggers import Timer

import os
from pathlib import Path
from cocotb_tools.runner import get_runner

@cocotb.test()
async def test_full_adder_4_bit(dut):
    """Test 4-bit full adder with all possible input combinations"""
    
    passed_count = 0
    total_count = 0
    
    # Test all possible 4-bit values for a and b, and both values of cin
    for a in range(16):  # 0 to 15 for 4-bit
        for b in range(16):  # 0 to 15 for 4-bit
            for cin in range(2):  # 0 or 1 for carry in
                dut.a.value = a
                dut.b.value = b
                dut.cin.value = cin
                
                await Timer(1, unit="ns")
                
                # Calculate expected result
                result = a + b + cin
                expected_sum = result & 0xF  # Lower 4 bits
                expected_cout = (result >> 4) & 0x1  # Carry out bit
                
                actual_sum = int(dut.sum.value)
                actual_cout = int(dut.cout.value)
                
                total_count += 1
                
                sum_match = actual_sum == expected_sum
                cout_match = actual_cout == expected_cout
                
                if sum_match and cout_match:
                    passed_count += 1
                
                status = "PASS" if (sum_match and cout_match) else "FAIL"
                
                assert sum_match, f"Sum mismatch at a={a}, b={b}, cin={cin}: got {actual_sum}, expected {expected_sum}"
                assert cout_match, f"Cout mismatch at a={a}, b={b}, cin={cin}: got {actual_cout}, expected {expected_cout}"

def runner():
    # --- Fill the information below ---
    
    # Path to all related Verilog files
    verilog_files = [
        "../full_adder_4_bit.v"
    ]
    
    # Top-level module name
    top_module = "full_adder_4_bit"
    
    # Test module name (normally it is the name of this file without .py
    # except your testcase is in other Python file)
    test_module = "full_adder_4_bit_test"
    
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