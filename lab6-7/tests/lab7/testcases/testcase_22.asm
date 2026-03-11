# Testcase 22: lw (load word)
addi x1, x0, 0      # x1 = 0 (base address)
lw x2, 0(x1)        # x2 = SignExt([Address]31:0)
