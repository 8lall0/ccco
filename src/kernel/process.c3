module kernel::process;
import kernel;
import kernel::types;
import std::io;
import kernel::page;


const PROCS_MAX = 8;
const PROC_UNUSED = 0;   // Unused process control structure
const PROC_RUNNABLE = 1;   // Runnable process

char[] __kernel_base @export("__kernel_base");

struct Process {
    int pid;                    // Process ID
    int state;                  // Process state: PROC_UNUSED or PROC_RUNNABLE
    Uint32_t sp;                // Stack pointer
    Uint8_t *page_table;
    Uint8_t[8192] stack;        // Kernel stack
}

fn void switch_context(Uint32_t *prev_sp, Uint32_t *next_sp) @naked @noinline {
    asm(`
        addi sp, sp, -13 * 4
        sw ra,  0  * 4(sp)
        sw s0,  1  * 4(sp)
        sw s1,  2  * 4(sp)
        sw s2,  3  * 4(sp)
        sw s3,  4  * 4(sp)
        sw s4,  5  * 4(sp)
        sw s5,  6  * 4(sp)
        sw s6,  7  * 4(sp)
        sw s7,  8  * 4(sp)
        sw s8,  9  * 4(sp)
        sw s9,  10 * 4(sp)
        sw s10, 11 * 4(sp)
        sw s11, 12 * 4(sp)
        sw sp, (a0)
        lw sp, (a1)
        lw ra,  0  * 4(sp)
        lw s0,  1  * 4(sp)
        lw s1,  2  * 4(sp)
        lw s2,  3  * 4(sp)
        lw s3,  4  * 4(sp)
        lw s4,  5  * 4(sp)
        lw s5,  6  * 4(sp)
        lw s6,  7  * 4(sp)
        lw s7,  8  * 4(sp)
        lw s8,  9  * 4(sp)
        lw s9,  10 * 4(sp)
        lw s10, 11 * 4(sp)
        lw s11, 12 * 4(sp)
        addi sp, sp, 13 * 4
        ret
    `);
}

Process[PROCS_MAX] procs; // All process control structures.

fn Process *create_process(Uint32_t pc) {
    // Find an unused process control structure.
    Process *proc = null;
    int i;
    for (i = 0; i < PROCS_MAX; i++) {
        if (procs[i].state == PROC_UNUSED) {
            proc = &procs[i];
            break;
        }
    }

    if (!proc) {
        kernel::_panic("no free process slots");
    }

    Uint32_t * sp = (Uint32_t *) &proc.stack;
    sp += 2048;
    for (int j = 0; j < 12; j++) {
        sp--;
        asm {
         sw $zero, [sp];
        }
    }
    // Setting RA
    sp--;
    asm {
        sw pc, [sp];
    }

    // Map kernel pages.
    Uint32_t *page_table = (Uint32_t *) kernel::alloc_pages(1);
    for (Paddr_t paddr = (Paddr_t) &__kernel_base; paddr < (Paddr_t) &kernel::__free_ram_end; paddr += page::PAGE_SIZE) {
        page::map_page(page_table, paddr, paddr, page::PAGE_R | page::PAGE_W | page::PAGE_X);
    }


    // Initialize fields.
    proc.pid = i + 1;
    proc.state = PROC_RUNNABLE;
    proc.sp = (Uint32_t) sp;
    return proc;
}

Process *current_proc; // Currently running process
Process *idle_proc;    // Idle process

fn void yield() {
    Process *next = idle_proc;
    for (int i = 0; i < PROCS_MAX; i++) {
        Process *proc = &procs[(current_proc.pid + i) % PROCS_MAX];
        if (proc.state == PROC_RUNNABLE && proc.pid > 0) {
            next = proc;
            break;
        }
    }

    if (next == current_proc) {
        return;
    }



    // Context switch
    Process *prev = current_proc;
    current_proc = next;
    Uint32_t o = (Uint32_t) page::SATP_SV32 | (Uint32_t) ((Uint32_t)next.page_table / page::PAGE_SIZE);
    Uint32_t n = (Uint32_t) &next.stack+2048;

    asm(`sfence.vma`);
    asm {
        lw $t1, [&o];
    }
    asm("csrw satp, t0");
    asm(`sfence.vma`);
    asm {
        lw $t0, [n];
    }
    asm("csrw sscratch, t0");

    switch_context(&prev.sp, &next.sp);
}