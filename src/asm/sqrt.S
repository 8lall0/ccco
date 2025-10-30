    .section .text
    .globl sqrt
    .type sqrt, @function

# double sqrt(double x)
# a0 = low 32 bits, a1 = high 32 bits (soft-float ABI)
# returns sqrt(x) in a0/a1
sqrt:
    call __softfloat_sqrt
    ret
