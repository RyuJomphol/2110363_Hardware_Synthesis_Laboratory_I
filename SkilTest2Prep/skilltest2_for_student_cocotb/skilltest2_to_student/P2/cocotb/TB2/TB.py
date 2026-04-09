import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock

# global variables
expected_data_values = 0
expected_data_valid = 0
expected_data_count = 0
actual_data_count = 0
BitDelayNs = int(1000000000 / 115200)

async def monitor_signals(dut):
    global expected_data_values, expected_data_valid, actual_data_count
    while True:
        await RisingEdge(dut.clk)
        if(dut.RxD_data_ready.value == 1):
            if(expected_data_valid == 1):
                assert dut.RxD_data.value == expected_data_values, f"Data mismatch: {dut.RxD_data.value} != {expected_data_values}"
                expected_data_valid = 0
                actual_data_count += 1
            else:
                assert False, f"Data valid signal is high but data is not expected: {dut.RxD_data.value} != {expected_data_values}"

async def sent_byte (dut, data):
    global expected_data_values, expected_data_valid, expected_data_count
    dut._log.info(f"Sending byte: {data:#04x}")
    expected_data_values = data
    expected_data_valid = 1
    data_byte = [(data>>i)%2 for i in range(8)]
    # sent the start bit
    dut.RxD.value = 0
    await Timer(BitDelayNs, units="ns")
    # sent the data bits
    for i in range(8):
        dut.RxD.value = data_byte[i]
        await Timer(BitDelayNs, units="ns")
    # sent the stop bit
    dut.RxD.value = 1
    await Timer(BitDelayNs, units="ns")
    # some idle time
    await Timer(BitDelayNs, units="ns")
    expected_data_count += 1


@cocotb.test()
async def tb_2(dut):
    dut._log.info("----------------------------------------")
    dut._log.info("Starting Test 1")

    # create the clock
    cocotb.start_soon(Clock(dut.clk, 40, units="ns").start())

    # start the monitor
    cocotb.start_soon(monitor_signals(dut))

    dut.RxD.value = 1
    await Timer(2000, units="ns")

    await sent_byte(dut, 0x55)
    await sent_byte(dut, 0x54)
    await sent_byte(dut, 0xFF)
    await sent_byte(dut, 0x00)
    await sent_byte(dut, 0xAA)
    await sent_byte(dut, 0xF0)
    await sent_byte(dut, 0x0F)

    await Timer(BitDelayNs * 12, units="ns")

    assert expected_data_count == actual_data_count, f"Expected {expected_data_count} packet but received {actual_data_count} packet"

    dut._log.info("Test 1 Finished")
    dut._log.info("----------------------------------------")
    await Timer(50, units="ns")
