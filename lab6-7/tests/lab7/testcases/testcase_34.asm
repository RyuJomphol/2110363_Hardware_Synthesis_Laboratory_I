# Testcase 34: jalr (jump and link register)
addi x1, x0, 8      # x1 = 8 (target address)
jalr x3, x1, 0      # jump to x1 + 0, x3 = PC + 4
addi x4, x0, 7      # x4 = 7 (should be skipped)
