module ccco;

import std::io;
import std::core::mem;

char[] __bss @export("__bss");
char[] __bss_end @export("__bss_end");
char[] __stack_top @export("__stack_top");

fn void boot() @naked @export("boot") @noinline @nostrip {
    asm("la t0, __stack_top");
    asm("mv sp, t0");
    asm("j kernel_main");
}

fn void kernel_main() @export("kernel_main") @noinline @nostrip {
    mem::set(&__bss, 0, &__bss_end - &__bss);
   // builtin::panic("PANIC!");

    io::printf("\n\nHello World!\n");
    String s1 = "pippo";
    String s2 = "pluto";
    io::printf("Checking strings %s and %s\n", s1, s2);

    if (s1 == s2) {
        io::printf("%s == %s\n", s1, s2);
    } else {
        io::printf("%s != %s\n", s1, s2);
    }

    for(;;) {
        asm {
            wfi;
        }
    }
}