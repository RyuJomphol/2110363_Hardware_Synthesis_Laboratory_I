# 1. Setup Stack Pointer and Data
addi    sp, zero, 16
addi    t0, zero, 15
sw      t0, 0(sp)
addi    t0, zero, 42
sw      t0, 4(sp)
addi    t0, zero, 7
sw      t0, 8(sp)
addi    t0, zero, 99
sw      t0, 12(sp)

# 2. Find Max Logic
# a0 = n (4), a1 = index (i), a2 = current_max
addi    a0, zero, 4
addi    a1, zero, 0
lw      a2, 0(sp)

LOOP:
    bge     a1, a0, EXIT        # ถ้า i >= n ให้จบการทำงาน
    slli    t1, a1, 2           # t1 = i * 4
    add     t1, t1, sp          # t1 = address ของ arr[i]
    lw      t2, 0(t1)           # t2 = ค่าของ arr[i]

    bge     a2, t2, SKIP        # ถ้า current_max >= arr[i] ให้ข้ามการ Update

    add     a2, t2, zero        # update current_max (ทำงานเมื่อ arr[i] > current_max)

SKIP:
    addi    a1, a1, 1           # i++
    jal     zero, LOOP          # วนกลับไป LOOP

EXIT:
    # Store result at Address 0
    sw      a2, 0(zero)
    addi    zero, zero, 0       # NOP
