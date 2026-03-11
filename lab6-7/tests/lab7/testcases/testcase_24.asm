# Testcase 24: lhu (load half unsigned)
addi x1, x0, 0      # x1 = 0 (base address)
lhu x2, 0(x1)       # x2 = ZeroExt([Address]15:0)
