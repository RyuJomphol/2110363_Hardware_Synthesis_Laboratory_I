# Testcase 33: bgeu (branch if greater or equal unsigned)
addi x1, x0, 5      # x1 = 5
addi x2, x0, 2      # x2 = 2
bgeu x1, x2, label6 # branch to label6 if x1 >= x2 (unsigned)
addi x3, x0, 0      # x3 = 0 (should be skipped)
label6:
addi x3, x0, 6      # x3 = 6 (should execute)
