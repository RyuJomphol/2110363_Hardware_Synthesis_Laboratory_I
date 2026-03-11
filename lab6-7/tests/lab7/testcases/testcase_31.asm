# Testcase 31: bge (branch if greater or equal)
addi x1, x0, 5      # x1 = 5
addi x2, x0, 2      # x2 = 2
bge x1, x2, label4  # branch to label4 if x1 >= x2
addi x3, x0, 0      # x3 = 0 (should be skipped)
label4:
addi x3, x0, 4      # x3 = 4 (should execute)
