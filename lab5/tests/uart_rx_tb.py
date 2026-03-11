import os
import random
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer
from cocotb_tools.runner import get_runner
from cocotbext.uart import UartSource


@cocotb.test()
async def test_uart_rx_alphabet_stress(dut):
    """
    Stress Test: Send 0-9, A-Z continuously
    with random DataReady timing to test the Handshake system.
    """

    # 1. Start 100MHz Clock (10ns)
    cocotb.start_soon(Clock(dut.Clk, 10, unit="ns").start())

    # 2. Create UART Source (Laptop simulation)
    # Set Baud rate to 115200 according to specification
    uart_source = UartSource(dut.Rx, baud=115200, bits=8)

    # 3. System Reset
    dut.Reset.value = 1
    dut.DataReady.value = 0
    await Timer(50, unit="ns")
    suffix_reset = 0
    dut.Reset.value = 0
    await Timer(50, unit="ns")

    # 4. Prepare 0-9, A-Z data
    test_string = b"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    # Command the Laptop to start sending all data in the background
    # so that the signal lines keep toggling while Python verifies the board values.
    cocotb.start_soon(uart_source.write(test_string))

    dut._log.info("Starting A-Z Stress Test...")

    for char_code in test_string:
        # --- Step 1: Wait until the module receives 1 full frame (10 bits) ---
        # The module must assert DataValid (TVALID)
        await RisingEdge(dut.DataValid)

        # Verify if the received data is correct
        received_val = int(dut.DataOut.value)
        assert received_val == char_code, (
            f"Error: Expected {chr(char_code)}({hex(char_code)}), got {hex(received_val)}"
        )

        # --- Step 2: Simulate Backpressure (Random Backpressure) ---
        # Artificially delay (random 0-500 ns) before asserting DataReady (TREADY)
        # to check if the UARTRx module holds DataValid high while waiting for us.
        wait_time = random.randint(0, 500)
        await Timer(wait_time, unit="ns")

        # Acknowledge data (Handshake Complete)
        dut.DataReady.value = 1

        # Wait until the module deasserts DataValid (because we are Ready)
        await FallingEdge(dut.DataValid)

        # Deassert Ready after finishing the reception of one character
        dut.DataReady.value = 0

        dut._log.info(
            f"Received '{chr(received_val)}' successfully (Wait: {wait_time}ns)"
        )

    dut._log.info("All characters A-Z received and verified with Handshake!")
    await Timer(100, unit="ns")


def runner():
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent
    # Specify the path to the source code file in the /src folder
    sources = [proj_path / "../src/UARTRx.v"]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="UARTRx",
        always=True,
        waves=True,
        timescale=("1ns", "1ps"),
    )
    runner.test(
        hdl_toplevel="UARTRx",
        test_module="uart_rx_tb",  # This Python filename
        waves=True,
    )


if __name__ == "__main__":
    runner()
