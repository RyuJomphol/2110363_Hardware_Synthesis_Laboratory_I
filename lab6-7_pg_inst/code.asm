START:
    lw x5, 80(x0)        # read switches
    andi x6, x5, 0xF     # x6 = operand A (SW0-3)
    srli x7, x5, 4       # shift right >>4
    andi x7, x7, 0xF     # x7 = operand B (SW4-7)
    addi x8, x0, 0       # result = 0

MULT_LOOP:
    andi x9, x7, 1       # check LSB of B
    beq x9, x0, SKIP     # skip if x9==0
    add x8, x8, x6       # result += A

SKIP:
    slli x6, x6, 1       # A = A << 1
    srli x7, x7, 1       # B = B >> 1
    bne x7, x0, MULT_LOOP
    sw x8, 84(x0)        # write result to LED
    jal x0, START        # loop forever