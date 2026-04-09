import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock

@cocotb.test()
async def tb_1(dut):
    dut._log.info("----------------------------------------")
    dut._log.info("Starting Test 1")
    # create the clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # 1. Initialize inputs
    dut.reset.value = 1
    dut.enable.value = 0
    await Timer(10, units="ns")
    dut.reset.value = 0

    # 2. Test Reset Functionality
    await Timer(10, units="ns")
    assert int(dut.lfsr_out) == 0xffff, "Reset Fail: LFSR should be 0xFFFF after reset"

    dut._log.info("Reset Test Finished")
    dut._log.info("----------------------------------------")

    await Timer(50, units="ns")

@cocotb.test()
async def tb_2(dut):
    dut._log.info("----------------------------------------")
    dut._log.info("Starting Test 2")
    # create the clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    expected_output = [0 for i in range(16)]

    # 1. Initialize the expected output
    expected_output[0]  = 0xfffe
    expected_output[1]  = 0xfffc
    expected_output[2]  = 0xfff8
    expected_output[3]  = 0xfff0
    expected_output[4]  = 0xffe1
    expected_output[5]  = 0xffc3
    expected_output[6]  = 0xff87
    expected_output[7]  = 0xff0f
    expected_output[8]  = 0xfe1e
    expected_output[9]  = 0xfc3c
    expected_output[10] = 0xf878
    expected_output[11] = 0xf0f0
    expected_output[12] = 0xe1e1
    expected_output[13] = 0xc3c2
    expected_output[14] = 0x8784
    expected_output[15] = 0x0f09

    # 2. Initialize inputs and reset
    dut.reset.value = 1
    dut.enable.value = 0
    await Timer(10, units="ns")
    dut.reset.value = 0

    # 3. Test LFSR Functionality
    for i in range(16):
        dut.enable.value = 1
        await Timer(10, units="ns")
        assert int(dut.lfsr_out) == expected_output[i], f"LFSR Test Fail: Expected {expected_output[i]:#06x}, got {dut.lfsr_out:#06x}"
        dut.enable.value = 0
        await Timer(10, units="ns")

    dut._log.info("LFSR Test Finished")
    dut._log.info("----------------------------------------")
    await Timer(50, units="ns")



