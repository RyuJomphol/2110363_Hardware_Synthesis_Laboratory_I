# Testcase 21: lh (load half)
addi x1, x0, 0      # x1 = 0 (base address)
lh x2, 0(x1)        # x2 = SignExt([Address]15:0)
