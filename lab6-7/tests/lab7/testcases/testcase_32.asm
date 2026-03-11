# Testcase 32: bltu (branch if less than unsigned)
addi x1, x0, 2      # x1 = 2
addi x2, x0, 5      # x2 = 5
bltu x1, x2, label5 # branch to label5 if x1 < x2 (unsigned)
addi x3, x0, 0      # x3 = 0 (should be skipped)
label5:
addi x3, x0, 5      # x3 = 5 (should execute)
