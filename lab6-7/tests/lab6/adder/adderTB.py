import cocotb
from cocotb.triggers import Timer
import random

import os
from pathlib import Path
from cocotb_tools.runner import get_runner


def get_width(dut):
    """Get WIDTH parameter from DUT."""
    try:
        return int(dut.WIDTH.value)
    except Exception:
        return len(dut.a)


@cocotb.test()
async def test_adder_basic(dut):
    """Basic deterministic tests."""

    width = get_width(dut)
    mask = (1 << width) - 1

    test_vectors = [
        (0, 0),
        (1, 1),
        (5, 10),
        (123, 456),
        (mask, 1),      # overflow case
        (mask, mask),
    ]

    for a, b in test_vectors:
        dut.a.value = a
        dut.b.value = b

        await Timer(1, unit="ns")

        expected = (a + b) & mask
        result = dut.sum.value

        assert result == expected, f"FAIL: {a} + {b} = {result}, expected {expected}"


@cocotb.test()
async def test_adder_random(dut):
    """Randomized tests."""

    width = get_width(dut)
    mask = (1 << width) - 1

    for _ in range(100):

        a = random.randint(0, mask)
        b = random.randint(0, mask)

        dut.a.value = a
        dut.b.value = b

        await Timer(1, unit="ns")

        expected = (a + b) & mask
        result = dut.sum.value

        assert result == expected, (
            f"Random FAIL: {a} + {b} = {result}, expected {expected}"
        )


def runner():

    sim = os.getenv("SIM", "icarus")

    sources = [
        Path("../../../src/adder.v")
    ]
    
    top_module = "adder"
    test_module = "adderTB"

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