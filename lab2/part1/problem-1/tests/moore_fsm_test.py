import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly, Timer

import os
from pathlib import Path
from cocotb_tools.runner import get_runner

state_map = {
    0: 0b000,
    1: 0b011,
    2: 0b100,
    3: 0b101,
    4: 0b010,
    5: 0b001,
}

@cocotb.test()
async def moore_fsm_test_1(dut):
    clock = Clock(dut.clk, 10, unit="ns")
    clock.start()

    dut.rst.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    await ReadOnly()
    assert int(dut.out.value) == 0

    testing_set = (1,0,1,1,0,1,1,0)
    expected_states = (1,2,1,2,3,2,3,5)

    for i in range(len(testing_set)):
        await RisingEdge(dut.clk)
        dut['in'].value = testing_set[i]
        await ReadOnly()
        assert dut.out.value == state_map[expected_states[i]], f"[Assertion {i}] Expected out is {state_map[expected_states[i]]}, but actual out is {dut.state.value}"
    
    await RisingEdge(dut.clk)
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    await ReadOnly()
    assert int(dut.out.value) == 0

    await RisingEdge(dut.clk)

@cocotb.test()
async def moore_fsm_test_2(dut):
    clock = Clock(dut.clk, 10, unit="ns")
    clock.start()

    dut.rst.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    await ReadOnly()
    assert int(dut.out.value) == 0

    testing_set = (0,1,0,0,1)
    expected_states = (1,4,1,4,5)

    for i in range(len(testing_set)):
        await RisingEdge(dut.clk)
        dut['in'].value = testing_set[i]
        await ReadOnly()
        assert dut.out.value == state_map[expected_states[i]], f"[Assertion {i}] Expected out is {state_map[expected_states[i]]}, but actual out is {dut.state.value}"
    
    await RisingEdge(dut.clk)
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    await ReadOnly()
    assert int(dut.out.value) == 0

    await RisingEdge(dut.clk)

def runner():
    verilog_files = ["../moore_fsm.v"]
    top_module = "moore_fsm"
    test_module = "moore_fsm_test"

    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent
    sources = [proj_path / Path(f) for f in verilog_files]

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