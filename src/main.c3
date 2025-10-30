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
    io::printf("First printf from stdlib adapted: %s\n", "YES IT'S WORKING");
   // builtin::panic("PANIC!");

    io::printf("\n\nHello World!, %d %d\n", 15, 9);
    io::printf("Checking strings pippo and pluto\n");

    String s1 = "pippo";
    String s2 = "pluto";
    if (s1 == s2) {
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