# Testcase 23: lbu (load byte unsigned)
addi x1, x0, 0      # x1 = 0 (base address)
lbu x2, 0(x1)       # x2 = ZeroExt([Address]7:0)
