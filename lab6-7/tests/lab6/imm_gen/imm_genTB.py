import os
import random
from pathlib import Path

import cocotb
from cocotb.triggers import Timer
from cocotb_tools.runner import get_runner


OPCODE_I = 0b0010011
OPCODE_LOAD = 0b0000011
OPCODE_S = 0b0100011
OPCODE_B = 0b1100011
OPCODE_JALR = 0b1100111
OPCODE_JAL = 0b1101111
OPCODE_LUI = 0b0110111
OPCODE_AUIPC = 0b0010111


def sign_extend(value, bits):
	sign_bit = 1 << (bits - 1)
	value &= (1 << bits) - 1
	if value & sign_bit:
		value -= 1 << bits
	return value & 0xFFFFFFFF


def reference_imm(inst):
	opcode = inst & 0x7F

	if opcode in (OPCODE_I, OPCODE_LOAD, OPCODE_JALR):
		imm12 = (inst >> 20) & 0xFFF
		return sign_extend(imm12, 12)

	if opcode == OPCODE_S:
		imm12 = (((inst >> 25) & 0x7F) << 5) | ((inst >> 7) & 0x1F)
		return sign_extend(imm12, 12)

	if opcode == OPCODE_B:
		imm13 = (
			((inst >> 31) & 0x1) << 12
			| ((inst >> 7) & 0x1) << 11
			| ((inst >> 25) & 0x3F) << 5
			| ((inst >> 8) & 0xF) << 1
		)
		return sign_extend(imm13, 13)

	if opcode in (OPCODE_LUI, OPCODE_AUIPC):
		return inst & 0xFFFFF000

	if opcode == OPCODE_JAL:
		imm21 = (
			((inst >> 31) & 0x1) << 20
			| ((inst >> 12) & 0xFF) << 12
			| ((inst >> 20) & 0x1) << 11
			| ((inst >> 21) & 0x3FF) << 1
		)
		return sign_extend(imm21, 21)

	return 0


def build_inst_with_opcode(opcode):
	# Fill non-opcode bits randomly so field extraction paths are exercised.
	upper = random.getrandbits(25)
	return (upper << 7) | opcode


@cocotb.test()
async def test_imm_gen_directed(dut):
	directed = [
		0x00000013,  # addi x0, x0, 0      -> I = 0
		0xFFF00013,  # addi x0, x0, -1     -> I = -1
		0x00112023,  # sw   x1, 0(x2)      -> S = 0
		0xFE112E23,  # sw   x1, -4(x2)      -> S = -4
		0x00000063,  # beq  x0, x0, 0      -> B = 0
		0xFE000EE3,  # beq  x0, x0, -4     -> B = -4
		0x0000006F,  # jal  x0, 0          -> J = 0
		0xFFDFF06F,  # jal  x0, -4         -> J = -4
		0x12345037,  # lui  x0, 0x12345    -> U = 0x12345000
		0xABCDE017,  # auipc x0, 0xABCDE   -> U = 0xABCDE000
		0xFFFFFFFF,  # unsupported opcode  -> 0
	]

	for inst in directed:
		dut.inst.value = inst
		await Timer(1, unit="step")

		expected = reference_imm(inst)
		got = int(dut.imm.value) & 0xFFFFFFFF

		assert got == expected, (
			f"Directed FAIL: inst=0x{inst:08X}, imm=0x{got:08X}, expected=0x{expected:08X}"
		)


@cocotb.test()
async def test_imm_gen_random(dut):
	opcodes = [
		OPCODE_I,
		OPCODE_LOAD,
		OPCODE_S,
		OPCODE_B,
		OPCODE_JALR,
		OPCODE_JAL,
		OPCODE_LUI,
		OPCODE_AUIPC,
	]

	for _ in range(500):
		opcode = random.choice(opcodes)
		inst = build_inst_with_opcode(opcode)

		dut.inst.value = inst
		await Timer(1, unit="step")

		expected = reference_imm(inst)
		got = int(dut.imm.value) & 0xFFFFFFFF

		assert got == expected, (
			f"Random FAIL: opcode=0b{opcode:07b}, inst=0x{inst:08X}, "
			f"imm=0x{got:08X}, expected=0x{expected:08X}"
		)


# @cocotb.test()
# async def test_imm_gen_unsupported_opcode_defaults_zero(dut):
# 	unsupported = [
# 		0b0110011,  # R-type ALU
# 		0b1110011,  # SYSTEM
# 		0b0001111,  # FENCE
# 	]

# 	for opcode in unsupported:
# 		inst = build_inst_with_opcode(opcode)
# 		dut.inst.value = inst
# 		await Timer(1, units="step")

# 		got = int(dut.imm.value) & 0xFFFFFFFF
# 		assert got == 0, (
# 			f"Default FAIL: opcode=0b{opcode:07b}, inst=0x{inst:08X}, imm=0x{got:08X}, expected=0"
# 		)


def runner():
	sim = os.getenv("SIM", "icarus")

	sources = [
		Path("../../../src/imm_gen.v"),
	]
 
	top_module = "imm_gen"
	test_module = "imm_genTB"

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
