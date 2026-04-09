import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock

async def apply_and_check(dut, inp, out, state_comment):
    dut.inp.value = inp
    await Timer(5, units="ns")
    dut._log.info(f"State: {state_comment}, Input: {inp}, Expected Output: {out}")
    assert dut.out.value == out, f"{state_comment} Fail: Output should be {out}"
    await Timer(5, units="ns")

@cocotb.test()
async def tb_reset(dut):

    dut._log.info("----------------------------------------")
    dut._log.info("Starting Reset Test")

    # create the clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # 1. Initialize and assert reset
    dut.reset.value = 1
    dut.inp.value = 0
    await Timer(20, units="ns")

    # 2. Deassert reset
    dut.reset.value = 0
    dut.inp.value = 0
    await Timer(10, units="ns")
    assert dut.out.value == 0, "Reset Fail: Output should be 0 after reset with in=0"

    # 3. Test reset assertion during operation (go to state B first)
    dut.inp.value = 1
    await Timer(10, units="ns")
    assert dut.out.value == 1, "Transition Fail: Output should be 1 in State B with in=1"

    await Timer(5, units="ns")
    dut.reset.value = 1
    await Timer(25, units="ns")

    dut.reset.value = 0
    dut.inp.value = 0
    await Timer(10, units="ns")
    assert dut.out.value == 0, "Mid-Reset Fail: Output should be 0 after reset with in=0"

    dut._log.info("Reset Test Finished")
    dut._log.info("----------------------------------------")
    await Timer(50, units="ns")

@cocotb.test()
async def tb_abc(dut):
    dut._log.info("----------------------------------------")
    dut._log.info("Starting States A, B, C Test")

    # create the clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # 1. Reset sequence
    dut.reset.value = 1
    dut.inp.value = 0
    await Timer(20, units="ns")
    dut.reset.value = 0
    await Timer(12, units="ns")

    # 2. Test transitions from A
    # A -> A (in=0, out=0)
    await apply_and_check(dut, 0, 0, "A->A")
    # A -> B (in=1, out=1)
    await apply_and_check(dut, 1, 1, "A->B")

    #3. Test transition from B (current state is B)
    # B -> B (in=0, out=0)
    await apply_and_check(dut, 0, 0, "B->B")

    #4. Test transitions from  C (current state is C)
    # C -> A (in=0, out=0)
    await apply_and_check(dut, 0, 0, "C->A")

    # Go Back to C to test C -> D (oartially tests D entry)
    # A -> B (in=1, out=1)
    await apply_and_check(dut, 1, 1, "A->B")

    # B -> C (in=0, out=0)
    await apply_and_check(dut, 0, 0, "B->C")

    # C -> D (in=1, out=0)
    await apply_and_check(dut, 1, 0, "C->D")

    dut._log.info("States A, B, C Test Finished")
    dut._log.info("----------------------------------------")
    await Timer(50, units="ns")

@cocotb.test()
async def tb_full(dut):
    dut._log.info("----------------------------------------")
    dut._log.info("Starting Full Test")

    # create the clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # 1. Reset sequence
    dut.reset.value = 1
    dut.inp.value = 0
    await Timer(20, units="ns")
    dut.reset.value = 0
    await Timer(12, units="ns")

    # 2. Cover all transitions (follow a path)
    # Current State: A
    await apply_and_check(dut, 0, 0, "A->A")
    await apply_and_check(dut, 1, 1, "A->B")

    # Current State: B
    await apply_and_check(dut, 1, 1, "B->D")

    # Current State: D
    await apply_and_check(dut, 1, 1, "D->D")
    await apply_and_check(dut, 0, 0, "D->E")

    # Current State: E
    await apply_and_check(dut, 0, 1, "E->D")

    # Current State: D (visited D->D, D->E; need to get back to other states)
    # Let's get back to E then A
    await apply_and_check(dut, 0, 0, "D->E")
    await apply_and_check(dut, 1, 0, "E->A")

    # Current State: A (visited A->A, A->B; need to get to C)
    await apply_and_check(dut, 1, 1, "A->B")
    await apply_and_check(dut, 0, 0, "B->C")

    # Current State: C (Need C->A, C->D)
    await apply_and_check(dut, 1, 0, "C->D")

    # Get back to C via E -> A -> B -> C
    await apply_and_check(dut, 0, 0, "D->E")
    await apply_and_check(dut, 1, 0, "E->A")
    await apply_and_check(dut, 1, 1, "A->B")
    await apply_and_check(dut, 0, 0, "B->C")

    # Current State: C (Test C->A)
    await apply_and_check(dut, 0, 0, "C->A")

    dut._log.info("Full Test Finished")
    dut._log.info("----------------------------------------")
    await Timer(50, units="ns")