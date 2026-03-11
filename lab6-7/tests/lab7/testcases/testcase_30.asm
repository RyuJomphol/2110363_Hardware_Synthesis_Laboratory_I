# Testcase 30: blt (branch if less than)
addi x1, x0, 2      # x1 = 2
addi x2, x0, 5      # x2 = 5
blt x1, x2, label3  # branch to label3 if x1 < x2
addi x3, x0, 0      # x3 = 0 (should be skipped)
label3:
addi x3, x0, 3      # x3 = 3 (should execute)
