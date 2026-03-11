addi x1, x0, 0      # x1 = 0 (base address)
lb x2, 0(x1)        # x2 = SignExt([0x7F]) if memory[0] = 0x7F