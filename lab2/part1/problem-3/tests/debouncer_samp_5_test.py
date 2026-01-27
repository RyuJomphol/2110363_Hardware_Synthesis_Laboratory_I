import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge, FallingEdge

import os
from pathlib import Path
from cocotb_tools.runner import get_runner

@cocotb.test()
async def debouncer_5_test(dut):
    input_rst = (0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0)
    input_data_in = (0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    output_data_out = (None, None, None, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0)
    clock = Clock(dut.clk, 10, unit="ns")
    clock.start(start_high=True)

    for i in range(0, len(input_rst), 2):
        dut.rst.value = input_rst[i]
        dut.data_in.value = input_data_in[i]
        await Timer(1, unit='ns')
        if output_data_out[i] is not None:    # Check waveform at falling edge
            assert dut.data_out.value == output_data_out[i], f"[Assertion {i}] Expected data_out to be {output_data_out[i]}, but got {dut.data_out.value}"
        await RisingEdge(dut.clk)
        if i+1 >= len(input_rst):
            break
        dut.rst.value = input_rst[i+1]
        dut.data_in.value = input_data_in[i+1]
        await Timer(1, unit='ns')
        if output_data_out[i+1] is not None:  # Check waveform at rising edge
            assert dut.data_out.value == output_data_out[i+1], f"[Assertion {i+1}] Expected data_out to be {output_data_out[i+1]}, but got {dut.data_out.value}"
        await FallingEdge(dut.clk)
        
def runner():
    # --- Fill the information below ---
    
    # Path to all related Verilog files
    verilog_files = [
        "../debouncer.v"
    ]
    
    # Top-level module name
    top_module = "debouncer"
    
    # Test module name (normally it is the name of this file without .py
    # except your testcase is in other Python file)
    test_module = "debouncer_samp_5_test"
    
    # Parameters
    parameters = {
        'SAMPLING_RATE': 5,
        'COUNTER_WIDTH': 3
    }
    
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
        parameters=parameters,
        timescale=('1ns','1ps')
    )
    
    runner.test(hdl_toplevel=top_module, test_module=test_module, waves=True, parameters=parameters)

if __name__ == "__main__":
    runner()