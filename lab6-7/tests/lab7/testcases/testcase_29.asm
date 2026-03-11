# Testcase 29: bne (branch if not equal)
addi x1, x0, 5      # x1 = 5
addi x2, x0, 3      # x2 = 3
bne x1, x2, label2  # branch to label2 if x1 != x2
addi x3, x0, 0      # x3 = 0 (should be skipped)
label2:
addi x3, x0, 2      # x3 = 2 (should execute)
