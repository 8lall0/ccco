module ccco;

import std::io;
import std::core::mem;
import std::core::builtin;
import libc;
import std::core::string;
import std::ascii;
import kernel;
import kernel::process;
import kernel::types;


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
    types::Uint32_t scause = read_reg("scause");
    types::Uint32_t stval = read_reg("stval");
    types::Uint32_t user_pc = read_reg("sepc");

    io::printfn("unexpected trap scause=%x, stval=%x, sepc=%x\n", scause, stval, user_pc);
    kernel::_panic("it's a trap!");
}

fn void kernel_entry() @align(4) @export("kernel_entry") @noinline @nostrip {
    asm(`
        csrw sscratch, sp
        addi sp, sp, -4 * 31
        sw ra,  4 * 0(sp)
        sw gp,  4 * 1(sp)
        sw tp,  4 * 2(sp)
        sw t0,  4 * 3(sp)
        sw t1,  4 * 4(sp)
        sw t2,  4 * 5(sp)
        sw t3,  4 * 6(sp)
        sw t4,  4 * 7(sp)
        sw t5,  4 * 8(sp)
        sw t6,  4 * 9(sp)
        sw a0,  4 * 10(sp)
        sw a1,  4 * 11(sp)
        sw a2,  4 * 12(sp)
        sw a3,  4 * 13(sp)
        sw a4,  4 * 14(sp)
        sw a5,  4 * 15(sp)
        sw a6,  4 * 16(sp)
        sw a7,  4 * 17(sp)
        sw s0,  4 * 18(sp)
        sw s1,  4 * 19(sp)
        sw s2,  4 * 20(sp)
        sw s3,  4 * 21(sp)
        sw s4,  4 * 22(sp)
        sw s5,  4 * 23(sp)
        sw s6,  4 * 24(sp)
        sw s7,  4 * 25(sp)
        sw s8,  4 * 26(sp)
        sw s9,  4 * 27(sp)
        sw s10, 4 * 28(sp)
        sw s11, 4 * 29(sp)
        csrr a0, sscratch
        sw a0, 4 * 30(sp)
        addi a0, sp, 4 * 31
        csrw sscratch, a0
        mv a0, sp
        call handle_trap
        lw ra,  4 * 0(sp)
        lw gp,  4 * 1(sp)
        lw tp,  4 * 2(sp)
        lw t0,  4 * 3(sp)
        lw t1,  4 * 4(sp)
        lw t2,  4 * 5(sp)
        lw t3,  4 * 6(sp)
        lw t4,  4 * 7(sp)
        lw t5,  4 * 8(sp)
        lw t6,  4 * 9(sp)
        lw a0,  4 * 10(sp)
        lw a1,  4 * 11(sp)
        lw a2,  4 * 12(sp)
        lw a3,  4 * 13(sp)
        lw a4,  4 * 14(sp)
        lw a5,  4 * 15(sp)
        lw a6,  4 * 16(sp)
        lw a7,  4 * 17(sp)
        lw s0,  4 * 18(sp)
        lw s1,  4 * 19(sp)
        lw s2,  4 * 20(sp)
        lw s3,  4 * 21(sp)
        lw s4,  4 * 22(sp)
        lw s5,  4 * 23(sp)
        lw s6,  4 * 24(sp)
        lw s7,  4 * 25(sp)
        lw s8,  4 * 26(sp)
        lw s9,  4 * 27(sp)
        lw s10, 4 * 28(sp)
        lw s11, 4 * 29(sp)
        lw sp,  4 * 30(sp)
        sret
    `);
}

process::Process *proc_a;
process::Process *proc_b;

fn void delay() {
    for (int i = 0; i < 30000000; i++) {
        asm("nop");
    }
}

fn void proc_a_entry() {
    io::printfn("starting process A\n");
    while (1) {
        io::printfn("A");
        process::yield();
    }
}

fn void proc_b_entry() {
    io::printfn("starting process B\n");
    while (1) {
        io::printfn("B");
        process::yield();
    }
}

fn void kernel_main() @export("kernel_main") @noinline @nostrip {
    asm(@sprintf("la t0, %s", &kernel_main));
    asm("csrw stvec, t0");
    io::printfn("\n\nHello World!\n");

    Process *idle_proc = process::create_process((Uint32_t) null);
    idle_proc.pid = 0; // idle
    process::current_proc = idle_proc;

    proc_a = process::create_process((types::Uint32_t) &proc_a_entry);
    proc_b = process::create_process((types::Uint32_t) &proc_b_entry);
    process::yield();
}