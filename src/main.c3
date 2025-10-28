module ccco;

import std::io;
import std::string;
import std::mem;
import std::types;
import std::core::builtin;

char[] __bss @export("__bss");
char[] __bss_end @export("__bss_end");
char[] __stack_top @export("__stack_top");

fn void boot() @naked @export("boot") @noinline @nostrip {
    asm("la t0, __stack_top");
    asm("mv sp, t0");
    asm("j kernel_main");
}

fn void kernel_main() @export("kernel_main") @noinline @nostrip {
    mem::memset(&__bss, 0, &__bss_end - &__bss);
    io::printf("Culo %s\n", "culo");
    builtin::panic("PANIC!");

    io::printf("\n\nHello World!, %d %d\n", 15, 9);
    io::printf("Checking strings pippo and pluto\n");

    ichar *s1 = "pippo";
    ichar *s2 = "pluto";
    if (!string::strcmp(s1, s1)) {
        io::printf("s1 == s2\n");
    } else {
        io::printf("s1 != s2\n");
    }
    for(;;) {
        asm {
            wfi;
        }
    }
}

struct Sbiret
{
    long error;
    long value;
}

fn Sbiret sbi_call(int arg0, int arg1, int arg2, int arg3, int arg4,
              int arg5, int fid, int eid) {

    Sbiret output;
    long result;

    asm {
         mv $a0, arg0;
         mv $a1, arg1;
         mv $a2, arg2;
         mv $a3, arg3;
         mv $a4, arg4;
         mv $a5, arg5;
         mv $a6, fid;
         mv $a7, eid;

         ecall;

         sw $a0, [&result];
    }

    output.value = 1;
    output.error = result;

    return output;
}

fn void putchar(char ch) {
    sbi_call(ch, 0, 0, 0, 0, 0, 0, 1);
}