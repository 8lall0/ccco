module std::kernel;

import std::types;
import std::core::mem;
import std::core::builtin;
import std::io;


const PAGE_SIZE = 4096;

macro _panic(String msg) {
    io::printfn("PANIC: %s - %s:%d\n", msg, $$FILE, $$LINE);
    for(;;) {
        asm {
            wfi;
        }
    }
}

char[] __free_ram @export("__free_ram");
char[] __free_ram_end @export("__free_ram_end");

fn types::Paddr_t alloc_pages(types::Uint32_t n)
{
    static types::Paddr_t next_paddr = (types::Paddr_t) &__free_ram;
    types::Paddr_t paddr = next_paddr;
    next_paddr += n * PAGE_SIZE;

    if (next_paddr > (types::Paddr_t) &__free_ram_end) {
        _panic("out of memory");
    }

    mem::set((void *) paddr, 0, n * PAGE_SIZE);

    return paddr;
}