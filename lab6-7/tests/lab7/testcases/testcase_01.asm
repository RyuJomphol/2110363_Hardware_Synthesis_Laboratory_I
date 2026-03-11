# Comprehensive ADDI tests
addi x1, x0, 1        # x1 = 1
addi x2, x1, 2        # x2 = 3
addi x3, x2, 3        # x3 = 6
addi x4, x3, 4        # x4 = 10
addi x5, x4, 5        # x5 = 15
addi x6, x0, 2047     # x6 = 2047 (max positive 12-bit imm)
addi x7, x0, -1       # x7 = -1
addi x8, x7, -2048    # x8 = -2049? (wraps via 12-bit imm)
addi x9, x0, 0        # x9 = 0
addi x0, x0, 123      # write to x0 (should stay zero)
