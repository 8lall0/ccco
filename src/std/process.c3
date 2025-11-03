module std::process;
import std::types;
import std::kernel;
import std::io;

const PROCS_MAX = 8;
const PROC_UNUSED = 0;   // Unused process control structure
const PROC_RUNNABLE = 1;   // Runnable process

struct Process {
    int pid;                    // Process ID
    int state;                  // Process state: PROC_UNUSED or PROC_RUNNABLE
    Uint32_t sp;                // Stack pointer
    Uint8_t[8192] stack;        // Kernel stack
}

fn void switch_context(Uint32_t *prev_sp, Uint32_t *next_sp) @naked {
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
    switch_context(&prev.sp, &next.sp);
}