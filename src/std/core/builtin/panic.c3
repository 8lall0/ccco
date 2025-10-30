module std::core::builtin;

import std::io;

macro panickku(String msg) {
    io::printf("PANIC: %s - %s:%d\n", msg, $$FILE, $$LINE);
    for(;;) {
        asm {
            wfi;
        }
    }
}