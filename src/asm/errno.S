__errno:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call _impure_ptr     # get address of current _reent structure
    lw   a0, 0(a0)       # load pointer to reent structure
    lw   a0, 0(a0)       # return address of its _errno member
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret
