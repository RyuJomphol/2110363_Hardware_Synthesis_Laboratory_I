# Testcase 35: jal (jump and link)
jal x3, label7      # jump to label7, x3 = PC + 4
addi x4, x0, 8      # x4 = 8 (should be skipped)
label7:
addi x4, x0, 9      # x4 = 9 (should execute)