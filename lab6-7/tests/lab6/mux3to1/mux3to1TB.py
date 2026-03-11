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


def is_all_x(value, width):
	return str(value).lower() == ("x" * width)


@cocotb.test()
async def test_mux3to1_basic(dut):
	width = get_width(dut)
	mask = (1 << width) - 1

	test_vectors = [
		(0, 0, 0),
		(1, 2, 3),
		(5, 10, 15),
		(0x12345678, 0x9ABCDEF0, 0x0F0F0F0F),
		(mask, 0, mask),
	]

	for s0, s1, s2 in test_vectors:
		s0 &= mask
		s1 &= mask
		s2 &= mask

		dut.s0.value = s0
		dut.s1.value = s1
		dut.s2.value = s2

		dut.sel.value = 0
		await Timer(1, unit="step")
		assert dut.out.value == s0, (
			f"FAIL sel=00: out={dut.out.value}, expected={s0}"
		)

		dut.sel.value = 1
		await Timer(1, unit="step")
		assert dut.out.value == s1, (
			f"FAIL sel=01: out={dut.out.value}, expected={s1}"
		)

		dut.sel.value = 2
		await Timer(1, unit="step")
		assert dut.out.value == s2, (
			f"FAIL sel=10: out={dut.out.value}, expected={s2}"
		)

		dut.sel.value = 3
		await Timer(1, unit="step")
		assert is_all_x(dut.out.value, width), (
			f"FAIL sel=11: out={str(dut.out.value)}, expected={'x' * width}"
		)


@cocotb.test()
async def test_mux3to1_random(dut):
	width = get_width(dut)
	mask = (1 << width) - 1

	for _ in range(100):
		s0 = random.randint(0, mask)
		s1 = random.randint(0, mask)
		s2 = random.randint(0, mask)

		dut.s0.value = s0
		dut.s1.value = s1
		dut.s2.value = s2

		for sel, expected in [(0, s0), (1, s1), (2, s2)]:
			dut.sel.value = sel
			await Timer(1, unit="step")
			assert dut.out.value == expected, (
				f"Random FAIL sel={sel:02b}: out={dut.out.value}, expected={expected}"
			)

		dut.sel.value = 3
		await Timer(1, unit="step")
		assert is_all_x(dut.out.value, width), (
			f"Random FAIL sel=11: out={dut.out.value}, expected={'x' * width}"
		)


def runner():
	sim = os.getenv("SIM", "icarus")

	sources = [
		Path("../../../src/mux3to1.v"),
	]

	top_module = "mux3to1"
	test_module = "mux3to1TB"

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
