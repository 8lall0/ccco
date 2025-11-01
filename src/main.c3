module ccco;

import std::io;
import std::core::mem;
import std::types;
import std::core::builtin;
import libc;
import std::core::string;
import std::ascii;
import std::kernel;


struct Trap_frame @packed {
    types::Uint32_t ra;
    types::Uint32_t gp;
    types::Uint32_t tp;
    types::Uint32_t t0;
    types::Uint32_t t1;
    types::Uint32_t t2;
    types::Uint32_t t3;
    types::Uint32_t t4;
    types::Uint32_t t5;
    types::Uint32_t t6;
    types::Uint32_t a0;
    types::Uint32_t a1;
    types::Uint32_t a2;
    types::Uint32_t a3;
    types::Uint32_t a4;
    types::Uint32_t a5;
    types::Uint32_t a6;
    types::Uint32_t a7;
    types::Uint32_t s0;
    types::Uint32_t s1;
    types::Uint32_t s2;
    types::Uint32_t s3;
    types::Uint32_t s4;
    types::Uint32_t s5;
    types::Uint32_t s6;
    types::Uint32_t s7;
    types::Uint32_t s8;
    types::Uint32_t s9;
    types::Uint32_t s10;
    types::Uint32_t s11;
    types::Uint32_t sp;
}

char[] __bss @export("__bss");
char[] __bss_end @export("__bss_end");
char[] __stack_top @export("__stack_top");

fn void boot() @naked @export("boot") @noinline @nostrip {
    asm(`
    la sp, __stack_top
    andi sp, sp, -16
    la t0, _sdata
    la t1, _edata
    la t2, _sidata
1:
    bge t0, t1, 2f
    lw t3, 0(t2)
    sw t3, 0(t0)
    addi t0, t0, 4
    addi t2, t2, 4
    j 1b
2:
    la t0, __bss
    la t1, __bss_end
3:
    bge t0, t1, 4f
    sw zero, 0(t0)
    addi t0, t0, 4
    j 3b
4:
    call kernel_main
hang:
    j hang`);
}

macro read_reg(String $reg)
{
    uptr x;
    asm(@sprintf("csrr a0, %s", $reg));
    asm { mv x, $a0; }
    return x;
}

macro write_reg(String $reg, String $value)
{
    asm(@sprintf("la t0, %s", $value));
    asm(@sprintf("csrw %s, t0", $reg));
}

fn void handle_trap(Trap_frame *f) @export("handle_trap") @noinline @nostrip {
    io::printfn("trap!\n");
    types::Uint32_t scause = read_reg("scause");
    types::Uint32_t stval = read_reg("stval");
    types::Uint32_t user_pc = read_reg("sepc");

    io::printfn("unexpected trap scause=%x, stval=%x, sepc=%x\n", scause, stval, user_pc);
    kernel::_panic("it's a trap!");
}

fn void kernel_entry() @align(4) @export("kernel_entry") @noinline @nostrip {
    asm("csrw sscratch, sp");
    asm("addi sp, sp, -4 * 31");
    asm("sw ra,  4 * 0(sp)");
    asm("sw gp,  4 * 1(sp)");
    asm("sw tp,  4 * 2(sp)");
    asm("sw t0,  4 * 3(sp)");
    asm("sw t1,  4 * 4(sp)");
    asm("sw t2,  4 * 5(sp)");
    asm("sw t3,  4 * 6(sp)");
    asm("sw t4,  4 * 7(sp)");
    asm("sw t5,  4 * 8(sp)");
    asm("sw t6,  4 * 9(sp)");
    asm("sw a0,  4 * 10(sp)");
    asm("sw a1,  4 * 11(sp)");
    asm("sw a2,  4 * 12(sp)");
    asm("sw a3,  4 * 13(sp)");
    asm("sw a4,  4 * 14(sp)");
    asm("sw a5,  4 * 15(sp)");
    asm("sw a6,  4 * 16(sp)");
    asm("sw a7,  4 * 17(sp)");
    asm("sw s0,  4 * 18(sp)");
    asm("sw s1,  4 * 19(sp)");
    asm("sw s2,  4 * 20(sp)");
    asm("sw s3,  4 * 21(sp)");
    asm("sw s4,  4 * 22(sp)");
    asm("sw s5,  4 * 23(sp)");
    asm("sw s6,  4 * 24(sp)");
    asm("sw s7,  4 * 25(sp)");
    asm("sw s8,  4 * 26(sp)");
    asm("sw s9,  4 * 27(sp)");
    asm("sw s10, 4 * 28(sp)");
    asm("sw s11, 4 * 29(sp)");
    asm("csrr a0, sscratch");
    asm("sw a0, 4 * 30(sp)");
    asm("mv a0, sp");
    asm("call handle_trap");
    asm("lw ra,  4 * 0(sp)");
    asm("lw gp,  4 * 1(sp)");
    asm("lw tp,  4 * 2(sp)");
    asm("lw t0,  4 * 3(sp)");
    asm("lw t1,  4 * 4(sp)");
    asm("lw t2,  4 * 5(sp)");
    asm("lw t3,  4 * 6(sp)");
    asm("lw t4,  4 * 7(sp)");
    asm("lw t5,  4 * 8(sp)");
    asm("lw t6,  4 * 9(sp)");
    asm("lw a0,  4 * 10(sp)");
    asm("lw a1,  4 * 11(sp)");
    asm("lw a2,  4 * 12(sp)");
    asm("lw a3,  4 * 13(sp)");
    asm("lw a4,  4 * 14(sp)");
    asm("lw a5,  4 * 15(sp)");
    asm("lw a6,  4 * 16(sp)");
    asm("lw a7,  4 * 17(sp)");
    asm("lw s0,  4 * 18(sp)");
    asm("lw s1,  4 * 19(sp)");
    asm("lw s2,  4 * 20(sp)");
    asm("lw s3,  4 * 21(sp)");
    asm("lw s4,  4 * 22(sp)");
    asm("lw s5,  4 * 23(sp)");
    asm("lw s6,  4 * 24(sp)");
    asm("lw s7,  4 * 25(sp)");
    asm("lw s8,  4 * 26(sp)");
    asm("lw s9,  4 * 27(sp)");
    asm("lw s10, 4 * 28(sp)");
    asm("lw s11, 4 * 29(sp)");
    asm("lw sp,  4 * 30(sp)");
    asm("sret");
}

fn void kernel_main() @export("kernel_main") @noinline @nostrip {
    io::printfn("\n\nHello World!\n");

    types::Paddr_t paddr0 = kernel::alloc_pages(2);
    types::Paddr_t paddr1 = kernel::alloc_pages(1);
    io::printfn("alloc_pages test: paddr0=%x\n", paddr0);
    io::printfn("alloc_pages test: paddr1=%x\n", paddr1);

    for (;;) {
        asm {
            wfi;
        }
    }
    //kernel::_panic("booted!");
}