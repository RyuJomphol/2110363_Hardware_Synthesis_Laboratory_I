# Testcase 26: sh (store half)
addi x1, x0, 0x10
addi x2, x0, 0x78C    
sh x2, 8(x1)
sh x2, -4(x1)
