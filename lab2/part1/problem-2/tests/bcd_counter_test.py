import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly

import os
from pathlib import Path
from cocotb_tools.runner import get_runner


@cocotb.test()
async def bcd_counter_test(dut):
    """
    Test BCD counter:
    - Reset
    - Count 0 -> 9
    - Rollover with cout
    """

    # Start clock (10 ns)
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    # --------------------
    # RESET (ทำครั้งเดียว!)
    # --------------------
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # ตรวจค่าหลัง reset
    await ReadOnly()
    assert int(dut.q.value) == 0
    assert int(dut.cout.value) == 0

    # --------------------
    # Expected values AFTER each rising edge
    # --------------------
    expected_counts = [
        (1, 0),
        (2, 0),
        (3, 0),
        (4, 0),
        (5, 0),
        (6, 0),
        (7, 0),
        (8, 0),
        (9, 1),
        (0, 0),  # rollover
        (1, 0),
    ]

    for expected_q, expected_carry in expected_counts:
        await RisingEdge(dut.clk)
        await ReadOnly()

        print(f"q={int(dut.q.value)}, carry={int(dut.cout.value)}")

        assert int(dut.q.value) == expected_q, \
            f"Expected q={expected_q}, got {int(dut.q.value)}"

        assert int(dut.cout.value) == expected_carry, \
            f"Expected cout={expected_carry}, got {int(dut.cout.value)}"


def runner():
    verilog_files = ["../bcd_counter.v"]
    top_module = "bcd_counter"
    test_module = "bcd_counter_test"

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
