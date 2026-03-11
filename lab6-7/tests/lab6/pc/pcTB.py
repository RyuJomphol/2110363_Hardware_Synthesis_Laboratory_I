import cocotb
from cocotb.triggers import Timer, RisingEdge
import random

import os
from pathlib import Path
from cocotb_tools.runner import get_runner
from cocotb.clock import Clock


@cocotb.test()
async def test_pc_reset_and_update(dut):
	"""Test synchronous reset and PC update."""
	# Initialize clock
	clock = Clock(dut.clk, 10, unit="ns")
	clock.start()
 
	# Reset should set current_pc to 0
	dut.rst.value = 1
	dut.next_pc.value = 123
	await RisingEdge(dut.clk)
	await Timer(1, unit="ns")
	assert dut.current_pc.value == 0, f"Reset FAIL: current_pc={dut.current_pc.value}, expected=0"

	# Release reset, update PC
	dut.rst.value = 0
	dut.next_pc.value = 42
	await RisingEdge(dut.clk)
	await Timer(1, unit="ns")
	assert dut.current_pc.value == 42, f"Update FAIL: current_pc={dut.current_pc.value}, expected=42"

	# Update PC again
	dut.next_pc.value = 99
	await RisingEdge(dut.clk)
	await Timer(1, unit="ns")
	assert dut.current_pc.value == 99, f"Update FAIL: current_pc={dut.current_pc.value}, expected=99"

	# Assert reset again
	dut.rst.value = 1
	dut.next_pc.value = 555
	await RisingEdge(dut.clk)
	await Timer(1, unit="ns")
	assert dut.current_pc.value == 0, f"Reset FAIL: current_pc={dut.current_pc.value}, expected=0"


@cocotb.test()
async def test_pc_random(dut):
	"""Randomized PC update tests."""
 	# Initialize clock
	clock = Clock(dut.clk, 10, unit="ns")
	clock.start()
 
	dut.rst.value = 1
	await RisingEdge(dut.clk)
	await Timer(1, unit="ns")
	dut.rst.value = 0

	for _ in range(20):
		val = random.randint(0, 0xFFFFFFFF)
		dut.next_pc.value = val
		await RisingEdge(dut.clk)
		await Timer(1, unit="ns")
		assert dut.current_pc.value == val, f"Random FAIL: current_pc={dut.current_pc.value}, expected={val}"


def runner():
	sim = os.getenv("SIM", "icarus")

	sources = [
		Path("../../../src/pc.v")
	]

	top_module = "pc"
	test_module = "pcTB"

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
