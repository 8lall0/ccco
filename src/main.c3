module ccco;

import std::io;

extern char[] __bss, __bss_end, __stack_top;

fn void boot() @naked @export("boot") @noinline @nostrip {
    asm("la t0, __stack_top");
    asm("mv sp, t0");
    asm("j kernel_main");
}

fn void kernel_main() @export("kernel_main") @noinline @nostrip {
    io::printf("\n\nHello World!, %d %d\n", 5, 9);
    for(;;) {
        asm {
            wfi;
        }
    }
}

