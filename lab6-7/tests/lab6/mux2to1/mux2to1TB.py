import cocotb
from cocotb.triggers import Timer
import random

import os
from pathlib import Path
from cocotb_tools.runner import get_runner


def get_width(dut):
    try:
        return int(dut.WIDTH.value)
    except Exception:
        return len(dut.s0)


@cocotb.test()
async def test_mux_random(dut):

    width = get_width(dut)
    mask = (1 << width) - 1

    for _ in range(100):

        s0 = random.randint(0, mask)
        s1 = random.randint(0, mask)

        dut.s0.value = s0
        dut.s1.value = s1

        # test sel = 0
        dut.sel.value = 0
        await Timer(1, unit="step")
        assert dut.out.value == s0, \
            f"FAIL sel=0: out={dut.out.value}, expected={s0}"

        # test sel = 1
        dut.sel.value = 1
        await Timer(1, unit="step")
        assert dut.out.value == s1, \
            f"FAIL sel=1: out={dut.out.value}, expected={s1}"


def runner():

    sim = os.getenv("SIM", "icarus")

    sources = [
        Path("../../../src/mux2to1.v")
    ]

    top_module = "mux2to1"
    test_module = "mux2to1TB"

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