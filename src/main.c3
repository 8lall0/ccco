module ccco;

extern char[] __bss, __bss_end, __stack_top;

fn void boot() @naked @export("boot") @noinline @nostrip {
    asm("la t0, __stack_top");
    asm("mv sp, t0");
    asm("j kernel_main");
}

fn void kernel_main() @export("kernel_main") @noinline @nostrip {
    const char *S = "\n\nHello World!\n";
    for (int i = 0; S[i] != '\0'; i++) {
      putchar(S[i]);
    }
    for(;;) {
        asm {
            wfi;
        }
    }
}

