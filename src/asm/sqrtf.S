    .section .text
    .global sqrtf
    .global sqrt
    .global sqrtl
    .type sqrtf, @function
    .type sqrt,  @function
    .type sqrtl, @function

# -------------------------
# sqrtf: approximate float sqrt
# Input:  a0 = float bits
# Output: a0 = float bits of sqrt(a0)
# -------------------------
sqrtf:
    addi sp, sp, -8
    sw   ra, 4(sp)

    # zero input -> zero output
    beqz a0, .sf_zero

    # negative input -> return 0 (short/simple)
    li t0, 0x80000000
    and t1, a0, t0
    bnez t1, .sf_zero

    # Quake-style inverse sqrt initial guess
    li t2, 0x5f3759df
    srli t3, a0, 1
    sub t4, t2, t3   # initial inv_sqrt estimate
    mv a1, t4

    # multiply x * inv_sqrt(x) to get sqrt approx
    mv a0, a0
    call float_mul

    j .sf_done

.sf_zero:
    li a0, 0

.sf_done:
    lw ra, 4(sp)
    addi sp, sp, 8
    ret

# -------------------------
# float_mul: approximate float multiplication
# Input: a0 = x_bits, a1 = y_bits
# Output: a0 = x*y bits
# -------------------------
float_mul:
    addi sp, sp, -20
    sw ra, 16(sp)
    sw s0, 12(sp)
    sw s1, 8(sp)
    sw s2, 4(sp)

    mv s0, a0
    mv s1, a1

    # extract sign
    xor t0, s0, s1
    srli t0, t0, 31   # result_sign

    # extract exponents
    srli t1, s0, 23
    andi t1, t1, 0xFF
    srli t2, s1, 23
    andi t2, t2, 0xFF

    # zero/denorm check
    beqz t1, .fm_zero
    beqz t2, .fm_zero

    # extract mantissas and add implicit 1
    li t3, 0x7FFFFF
    and t4, s0, t3
    li t0, 0x800000
    add t4, t4, t0       # mant_x
    and t5, s1, t3
    add t5, t5, t0       # mant_y

    # exponent result = exp_x + exp_y - 127
    add t6, t1, t2
    addi t6, t6, -127

    # multiply mantissas: 24x24 -> 48-bit
    mul t7, t4, t5       # low 32 bits
    mulhu t8, t4, t5     # high 32 bits

    # normalize if top bit set
    li t9, 0x8000
    and t9, t8, t9
    beqz t9, .fm_no_shift
    srli t10, t7, 1
    slli t11, t8, 31
    or t7, t10, t11
    srli t8, t8, 1
    addi t6, t6, 1
.fm_no_shift:

    # assemble top 24 bits
    slli t10, t8, 8
    srli t11, t7, 24
    or t12, t10, t11

    # mantissa = lower 23 bits
    li t13, 0x7FFFFF
    and t13, t12, t13

    # clamp exponent <255, else INF
    li t14, 0xFF
    bltu t6, t14, .fm_pack
    li t16, 0x7F800000
    slli t15, t0, 31
    or a0, t15, t16
    j .fm_done

.fm_pack:
    andi t6, t6, 0xFF
    slli t17, t6, 23
    slli t15, t0, 31
    or a0, t15, t17
    or a0, a0, t13

.fm_zero:
    li a0, 0

.fm_done:
    lw ra, 16(sp)
    lw s0, 12(sp)
    lw s1, 8(sp)
    lw s2, 4(sp)
    addi sp, sp, 20
    ret

# -------------------------
# sqrt (double) wrapper (approximate)
# Input: a0=lo, a1=hi of double
# Output: a0=lo, a1=hi of sqrt(double)
# -------------------------
sqrt:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)

    mv s0, a1
    beqz s0, .sd_zero

    # extract double exponent
    srli t0, s0, 20
    andi t0, t0, 0x7FF
    beqz t0, .sd_zero

    # float exponent = double_exp -1023 +127 = double_exp -896
    addi t1, t0, -896
    blt t1, zero_float_exp, .sd_zero
    li t2, 255
    bgeu t1, t2, .sd_inf

    # float mantissa: top 23 bits of double
    li t3, 0xFFFFF
    and t4, s0, t3
    srli t5, a0, 29
    slli t6, t4, 3
    or t6, t6, t5

    # assemble float
    andi t7, s0, 0x80000000
    slli t8, t1, 23
    or a0, t7, t8
    andi t6, t6, 0x7FFFFF
    or a0, a0, t6

    call sqrtf

    # convert float result -> double
    mv t9, a0
    andi t10, t9, 0x80000000
    srli t11, t9, 23
    andi t11, t11, 0xFF
    addi t12, t11, 896
    andi t13, t9, 0x7FFFFF
    slli t14, t12, 20
    srli t15, t13, 3
    or a1, t10, t14
    or a1, a1, t15
    andi t16, t13, 7
    slli a0, t16, 29

    lw ra, 12(sp)
    lw s0, 8(sp)
    addi sp, sp, 16
    ret

.zero_float_exp:
    li t0, 0

.sd_zero:
    li a0, 0
    li a1, 0
    lw ra, 12(sp)
    lw s0, 8(sp)
    addi sp, sp, 16
    ret

.sd_inf:
    li a1, 0x7FF00000
    li a0, 0
    lw ra, 12(sp)
    lw s0, 8(sp)
    addi sp, sp, 16
    ret

# -------------------------
# sqrtl alias -> sqrt
sqrtl:
    j sqrt
