# Testcase 28: beq (branch if equal)
addi x1, x0, 5      # x1 = 5
addi x2, x0, 5      # x2 = 5
beq x1, x2, label1  # branch to label1 if x1 == x2
addi x3, x0, 0      # x3 = 0 (should be skipped)
label1:
addi x3, x0, 1      # x3 = 1 (should execute)
