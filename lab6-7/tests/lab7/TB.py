import os
from pathlib import Path

import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock

from cocotb_tools.runner import get_runner


class CPU:
    def __init__(self):
        self.pc = 0
        self.registers = [0] * 32
        self.memory = [0] * 128
        self.instruction_memory = [0] * 128
        self.instruction_count = 0
        self.registers[2] = 128

    def load_instruction_memory(self, instruction_file_name, dut):
        with open(Path(os.path.dirname(os.path.abspath(__file__))) / instruction_file_name, "r") as f:
            self.instruction_memory = [int(line.strip(), 2) for line in f.readlines()]
        for i in range(len(self.instruction_memory)):
            dut.imem_inst.insts[i].value = self.instruction_memory[i]
        self.instruction_count = len(self.instruction_memory)
        print("Instruction memory loaded with {} instructions.".format(self.instruction_count))

    def fetch_instruction(self):
        # print(self.pc, self.instruction_memory[self.pc : self.pc + 4])
        return (
            (self.instruction_memory[self.pc] << 24)
            | (self.instruction_memory[self.pc + 1] << 16)
            | (self.instruction_memory[self.pc + 2] << 8)
            | self.instruction_memory[self.pc + 3]
        )

    def convert_int_to_2scomplement(self, value):
        if value < 0:
            return (1 << 32) + value
        else:
            return value

    def convert_immediate_to_int(self, value, length):
        if (value >> (length - 1)) & 0x1:
            return value - (1 << length)
        else:
            return value

    def check_result(self, dut):
        # check registers value
        for i in range(32):
            # print(
            #     "debug register value",
            #     i,
            #     dut.m_Register.regs[i].value,
            #     self.registers[i],
            # )
            assert dut.registers_inst.regs[i].value == self.convert_int_to_2scomplement(
                self.registers[i]
            ), "Register value mismatch at register x{}".format(i)
            # dut._log.info("Register x{}: Pass".format(i))
        # check memory value
        for i in range(128):
            # DEBUG
            if (self.memory[i] != 0):
                print("debug memory value", i, dut.dmem_inst.memory[i].value, self.memory[i])
                
            assert dut.dmem_inst.memory[i].value == self.memory[i], (
                "Memory value mismatch at address {}".format(i)
            )
            # dut._log.info("Memory address {}: Pass".format(i))

    def execute_one_instruction(self):

        if self.pc >= self.instruction_count:
            print(self.pc, self.instruction_count)
            print("Program execution completed.")
            # end of program
            return False

        # fetch instruction
        instruction = self.fetch_instruction()

        # execute instruction
        opcode = instruction & 0x7F

        def to_signed32(v):
            return v - (1 << 32) if v & (1 << 31) else v

        if opcode == 0x33:
            # R-type
            rd = (instruction >> 7) & 0x1F
            funct3 = (instruction >> 12) & 0x7
            rs1 = (instruction >> 15) & 0x1F
            rs2 = (instruction >> 20) & 0x1F
            funct7 = (instruction >> 25) & 0x7F
            if funct3 == 0x0 and funct7 == 0x00:
                # ADD Function
                self.registers[rd] = self.convert_immediate_to_int(
                    ((self.registers[rs1] + self.registers[rs2]) & 0xFFFFFFFF), 32
                )
            elif funct3 == 0x0 and funct7 == 0x20:
                # SUB Function
                self.registers[rd] = self.convert_immediate_to_int(
                    ((self.registers[rs1] - self.registers[rs2]) & 0xFFFFFFFF), 32
                )
            elif funct3 == 0x1 and funct7 == 0x00:
                # SLL Function
                sh = self.registers[rs2] & 0x1F
                self.registers[rd] = (self.registers[rs1] << sh) & 0xFFFFFFFF
            elif funct3 == 0x4 and funct7 == 0x00:
                # XOR
                self.registers[rd] = self.registers[rs1] ^ self.registers[rs2]
            elif funct3 == 0x7 and funct7 == 0x00:
                # AND Function
                self.registers[rd] = self.registers[rs1] & self.registers[rs2]
            elif funct3 == 0x6 and funct7 == 0x00:
                # OR Function
                self.registers[rd] = self.registers[rs1] | self.registers[rs2]

            elif funct3 == 0x2 and funct7 == 0x00:
                # SLT Function
                if self.registers[rs1] < self.registers[rs2]:
                    self.registers[rd] = 1
                else:
                    self.registers[rd] = 0
            elif funct3 == 0x3 and funct7 == 0x00:
                # SLTU (unsigned)
                if (self.registers[rs1] & 0xFFFFFFFF) < (
                    self.registers[rs2] & 0xFFFFFFFF
                ):
                    self.registers[rd] = 1
                else:
                    self.registers[rd] = 0
            elif funct3 == 0x5:
                # SRL or SRA
                sh = self.registers[rs2] & 0x1F
                if funct7 == 0x00:
                    # SRL logical
                    self.registers[rd] = (self.registers[rs1] & 0xFFFFFFFF) >> sh
                elif funct7 == 0x20:
                    # SRA arithmetic
                    val = to_signed32(self.registers[rs1] & 0xFFFFFFFF)
                    self.registers[rd] = (val >> sh) & 0xFFFFFFFF
            self.pc += 4
        elif opcode == 0x13:
            # I-type
            imm = instruction >> 20
            rd = (instruction >> 7) & 0x1F
            funct3 = (instruction >> 12) & 0x7
            rs1 = (instruction >> 15) & 0x1F
            if funct3 == 0x0:
                # ADDI Function
                self.registers[rd] = self.convert_immediate_to_int(
                    (
                        (self.registers[rs1] + self.convert_immediate_to_int(imm, 12))
                        & 0xFFFFFFFF
                    ),
                    32,
                )
            elif funct3 == 0x1:
                # SLLI (shamt in imm[4:0])
                sh = imm & 0x1F
                self.registers[rd] = (self.registers[rs1] << sh) & 0xFFFFFFFF
            elif funct3 == 0x7:
                # ANDI Function
                self.registers[rd] = self.registers[
                    rs1
                ] & self.convert_immediate_to_int(imm, 12)

            elif funct3 == 0x4:
                # XORI
                self.registers[rd] = self.registers[
                    rs1
                ] ^ self.convert_immediate_to_int(imm, 12)

            elif funct3 == 0x3:
                # SLTIU (unsigned compare with immediate interpreted as signed in spec, but keep unsigned compare)
                imm_val = self.convert_immediate_to_int(imm, 12)
                if (self.registers[rs1] & 0xFFFFFFFF) < (imm_val & 0xFFFFFFFF):
                    self.registers[rd] = 1
                else:
                    self.registers[rd] = 0

            elif funct3 == 0x5:
                # SRLI / SRAI
                sh = imm & 0x1F
                funct7_imm = (imm >> 5) & 0x7F
                if funct7_imm == 0x00:
                    # SRLI
                    self.registers[rd] = (self.registers[rs1] & 0xFFFFFFFF) >> sh
                else:
                    # SRAI (funct7 == 0x20 or similar encoding)
                    val = to_signed32(self.registers[rs1] & 0xFFFFFFFF)
                    self.registers[rd] = (val >> sh) & 0xFFFFFFFF

            elif funct3 == 0x6:
                # ORI Function
                self.registers[rd] = self.registers[
                    rs1
                ] | self.convert_immediate_to_int(imm, 12)
            elif funct3 == 0x2:
                # SLTI Function
                if self.registers[rs1] < self.convert_immediate_to_int(imm, 12):
                    self.registers[rd] = 1
                else:
                    self.registers[rd] = 0
            self.pc += 4
        elif opcode == 0x3:
            # I-type Load
            imm = instruction >> 20
            rd = (instruction >> 7) & 0x1F
            funct3 = (instruction >> 12) & 0x7
            rs1 = (instruction >> 15) & 0x1F
            base = self.registers[rs1] + self.convert_immediate_to_int(imm, 12)
            if funct3 == 0x2:
                # LW
                data_to_load = (
                    self.memory[base]
                    | (self.memory[base + 1] << 8)
                    | (self.memory[base + 2] << 16)
                    | (self.memory[base + 3] << 24)
                )
                self.registers[rd] = self.convert_immediate_to_int(data_to_load, 32)
            elif funct3 == 0x0:
                # LB - sign extend byte
                b = self.memory[base] & 0xFF
                if b & 0x80:
                    self.registers[rd] = b - (1 << 8)
                else:
                    self.registers[rd] = b
            elif funct3 == 0x1:
                # LH - sign extend halfword
                h = self.memory[base] | (self.memory[base + 1] << 8)
                if h & 0x8000:
                    self.registers[rd] = h - (1 << 16)
                else:
                    self.registers[rd] = h
            elif funct3 == 0x4:
                # LBU - zero extend byte
                self.registers[rd] = self.memory[base] & 0xFF
            elif funct3 == 0x5:
                # LHU - zero extend halfword
                self.registers[rd] = (
                    self.memory[base] | (self.memory[base + 1] << 8)
                ) & 0xFFFF
            self.pc += 4
        elif opcode == 0x23:
            # S-type Store
            offset = self.convert_immediate_to_int(
                ((instruction >> 25) << 5) | ((instruction >> 7) & 0x1F), 12
            )
            rs1 = (instruction >> 15) & 0x1F
            rs2 = (instruction >> 20) & 0x1F
            addr = self.registers[rs1] + offset
            funct3 = (instruction >> 12) & 0x7
            if funct3 == 0x2:
                # SW - store word
                data_to_store = self.convert_int_to_2scomplement(self.registers[rs2])
                self.memory[addr] = data_to_store & 0xFF
                self.memory[addr + 1] = (data_to_store >> 8) & 0xFF
                self.memory[addr + 2] = (data_to_store >> 16) & 0xFF
                self.memory[addr + 3] = (data_to_store >> 24) & 0xFF
            elif funct3 == 0x0:
                # SB - store byte
                self.memory[addr] = self.registers[rs2] & 0xFF
            elif funct3 == 0x1:
                # SH - store halfword
                val = self.registers[rs2] & 0xFFFF
                self.memory[addr] = val & 0xFF
                self.memory[addr + 1] = (val >> 8) & 0xFF
            self.pc += 4
        elif opcode == 0x63:
            # B-type
            offset = (
                (instruction >> 31) << 12
                | ((instruction >> 25) & 0x3F) << 5
                | ((instruction >> 8) & 0xF) << 1
                | (((instruction >> 7) & 0x1) << 11)
            )
            rs1 = (instruction >> 15) & 0x1F
            rs2 = (instruction >> 20) & 0x1F
            funct3 = (instruction >> 12) & 0x7
            if funct3 == 0x0:
                # BEQ Function
                if self.registers[rs1] == self.registers[rs2]:
                    self.pc += self.convert_immediate_to_int(offset, 13)
                else:
                    self.pc += 4
            elif funct3 == 0x1:
                # BNE Function
                if self.registers[rs1] != self.registers[rs2]:
                    self.pc += self.convert_immediate_to_int(offset, 13)
                else:
                    self.pc += 4
            elif funct3 == 0x4:
                # BLT Function
                if self.registers[rs1] < self.registers[rs2]:
                    self.pc += self.convert_immediate_to_int(offset, 13)
                else:
                    self.pc += 4
            elif funct3 == 0x5:
                # BGE Function
                if self.registers[rs1] >= self.registers[rs2]:
                    self.pc += self.convert_immediate_to_int(offset, 13)
                else:
                    self.pc += 4
            elif funct3 == 0x6:
                # BLTU (unsigned)
                if (self.registers[rs1] & 0xFFFFFFFF) < (
                    self.registers[rs2] & 0xFFFFFFFF
                ):
                    self.pc += self.convert_immediate_to_int(offset, 13)
                else:
                    self.pc += 4
            elif funct3 == 0x7:
                # BGEU (unsigned)
                if (self.registers[rs1] & 0xFFFFFFFF) >= (
                    self.registers[rs2] & 0xFFFFFFFF
                ):
                    self.pc += self.convert_immediate_to_int(offset, 13)
                else:
                    self.pc += 4
        elif opcode == 0x6F:
            # J-type
            imm = (
                (instruction >> 31) << 20
                | ((instruction >> 12) & 0xFF) << 12
                | ((instruction >> 20) & 0x1) << 11
                | ((instruction >> 21) & 0x3FF) << 1
            )
            rd = (instruction >> 7) & 0x1F
            # JAL Function
            self.registers[rd] = self.pc + 4
            self.pc += self.convert_immediate_to_int(imm, 21)
        elif opcode == 0x37:
            # LUI
            rd = (instruction >> 7) & 0x1F
            imm20 = instruction & 0xFFFFF000
            self.registers[rd] = self.convert_immediate_to_int(imm20, 32)
            self.pc += 4
        elif opcode == 0x17:
            # AUIPC
            rd = (instruction >> 7) & 0x1F
            imm20 = instruction & 0xFFFFF000
            self.registers[rd] = (
                self.pc + self.convert_immediate_to_int(imm20, 32)
            ) & 0xFFFFFFFF
            self.pc += 4
        elif opcode == 0x67:
            # I-type
            imm = instruction >> 20
            rd = (instruction >> 7) & 0x1F
            rs1 = (instruction >> 15) & 0x1F
            # JALR Function
            self.registers[rd] = self.pc + 4
            self.pc = (
                self.registers[rs1] + self.convert_immediate_to_int(imm, 12)
            ) & 0xFFFFFFFE
        elif instruction == 0x0:
            # NOP
            self.pc += 4
        self.registers[0] = 0
        return True


async def run_testcase(dut, testcase_filename):
    # set timeout in case of infinite loop
    program_running_limit = 10000
    """Try accessing the design."""
    # create the clock
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    # create the CPU
    virtual_cpu = CPU()
    # load instruction memory
    virtual_cpu.load_instruction_memory(testcase_filename, dut)
    dut._log.info("Running test from file: " + testcase_filename)
    # reset
    dut.testcase_id.value = int(testcase_filename.split("_")[-1].split(".")[0])
    dut.sw.value = 0
    dut.rst.value = 1
    await Timer(15, unit="ns")
    dut.rst.value = 0
    virtual_cpu.check_result(dut)
    dut._log.info("Reset Complete")
    await Timer(10, unit="ns")
    while virtual_cpu.execute_one_instruction() and program_running_limit > 0:
        # check result
        virtual_cpu.check_result(dut)
        await Timer(10, unit="ns")
        program_running_limit -= 1
    dut._log.info("Test Complete")


@cocotb.test()
async def Testcase01(dut):
    await run_testcase(dut, "./testcases/testcase_01.txt")


@cocotb.test()
async def Testcase02(dut):
    await run_testcase(dut, "./testcases/testcase_02.txt")


@cocotb.test()
async def Testcase03(dut):
    await run_testcase(dut, "./testcases/testcase_03.txt")


@cocotb.test()
async def Testcase04(dut):
    await run_testcase(dut, "./testcases/testcase_04.txt")


@cocotb.test()
async def Testcase05(dut):
    await run_testcase(dut, "./testcases/testcase_05.txt")


@cocotb.test()
async def Testcase06(dut):
    await run_testcase(dut, "./testcases/testcase_06.txt")


@cocotb.test()
async def Testcase07(dut):
    await run_testcase(dut, "./testcases/testcase_07.txt")


@cocotb.test()
async def Testcase08(dut):
    await run_testcase(dut, "./testcases/testcase_08.txt")


@cocotb.test()
async def Testcase09(dut):
    await run_testcase(dut, "./testcases/testcase_09.txt")


@cocotb.test()
async def Testcase10(dut):
    await run_testcase(dut, "./testcases/testcase_10.txt")


@cocotb.test()
async def Testcase11(dut):
    await run_testcase(dut, "./testcases/testcase_11.txt")


@cocotb.test()
async def Testcase12(dut):
    await run_testcase(dut, "./testcases/testcase_12.txt")


@cocotb.test()
async def Testcase13(dut):
    await run_testcase(dut, "./testcases/testcase_13.txt")


@cocotb.test()
async def Testcase14(dut):
    await run_testcase(dut, "./testcases/testcase_14.txt")


@cocotb.test()
async def Testcase15(dut):
    await run_testcase(dut, "./testcases/testcase_15.txt")


@cocotb.test()
async def Testcase16(dut):
    await run_testcase(dut, "./testcases/testcase_16.txt")


@cocotb.test()
async def Testcase17(dut):
    await run_testcase(dut, "./testcases/testcase_17.txt")


@cocotb.test()
async def Testcase18(dut):
    await run_testcase(dut, "./testcases/testcase_18.txt")


@cocotb.test()
async def Testcase19(dut):
    await run_testcase(dut, "./testcases/testcase_19.txt")


@cocotb.test()
async def Testcase20(dut):
    await run_testcase(dut, "./testcases/testcase_20.txt")


@cocotb.test()
async def Testcase21(dut):
    await run_testcase(dut, "./testcases/testcase_21.txt")


@cocotb.test()
async def Testcase22(dut):
    await run_testcase(dut, "./testcases/testcase_22.txt")


@cocotb.test()
async def Testcase23(dut):
    await run_testcase(dut, "./testcases/testcase_23.txt")


@cocotb.test()
async def Testcase24(dut):
    await run_testcase(dut, "./testcases/testcase_24.txt")


@cocotb.test()
async def Testcase25(dut):
    await run_testcase(dut, "./testcases/testcase_25.txt")


@cocotb.test()
async def Testcase26(dut):
    await run_testcase(dut, "./testcases/testcase_26.txt")


@cocotb.test()
async def Testcase27(dut):
    await run_testcase(dut, "./testcases/testcase_27.txt")


@cocotb.test()
async def Testcase28(dut):
    await run_testcase(dut, "./testcases/testcase_28.txt")


@cocotb.test()
async def Testcase29(dut):
    await run_testcase(dut, "./testcases/testcase_29.txt")


@cocotb.test()
async def Testcase30(dut):
    await run_testcase(dut, "./testcases/testcase_30.txt")


@cocotb.test()
async def Testcase31(dut):
    await run_testcase(dut, "./testcases/testcase_31.txt")


@cocotb.test()
async def Testcase32(dut):
    await run_testcase(dut, "./testcases/testcase_32.txt")


@cocotb.test()
async def Testcase33(dut):
    await run_testcase(dut, "./testcases/testcase_33.txt")


@cocotb.test()
async def Testcase34(dut):
    await run_testcase(dut, "./testcases/testcase_34.txt")


@cocotb.test()
async def Testcase35(dut):
    await run_testcase(dut, "./testcases/testcase_35.txt")


@cocotb.test()
async def Testcase36(dut):
    await run_testcase(dut, "./testcases/testcase_36.txt")


@cocotb.test()
async def Testcase37(dut):
    await run_testcase(dut, "./testcases/testcase_37.txt")


@cocotb.test()
async def Testcase38(dut):
    await run_testcase(dut, "./testcases/testcase_38.txt")


@cocotb.test()
async def Testcase39(dut):
    await run_testcase(dut, "./testcases/testcase_39.txt")


@cocotb.test()
async def Testcase40(dut):
    await run_testcase(dut, "./testcases/testcase_40.txt")


def runner():
    verilog_files = [f"../../src/{f}" for f in os.listdir("../../src") if f.endswith(".v")]
    top_module = "single_cycle_cpu"
    test_module = "TB"

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
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    runner()