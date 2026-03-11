# Testcase 25: sb (store byte)
addi x1, x0, 0      # x1 = 0 (base address)
addi x2, x0, 0x7F   # x2 = 0x7F (byte value)
sb x2, 0(x1)        # [Address]7:0 = x2[7:0]
