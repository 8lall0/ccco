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

fn void switch_context(Uint32_t *prev_sp, Uint32_t *next_sp) @export("switch_context") @align(4) {
    // Save callee-saved registers onto the current process's stack.
    asm {
        lw $t0, [prev_sp];
        lw $t1, [next_sp];
    }
    asm(`
        sw ra,  0  * 4(t0)
        sw s0,  1  * 4(t0)
        sw s1,  2  * 4(t0)
        sw s2,  3  * 4(t0)
        sw s3,  4  * 4(t0)
        sw s4,  5  * 4(t0)
        sw s5,  6  * 4(t0)
        sw s6,  7  * 4(t0)
        sw s7,  8  * 4(t0)
        sw s8,  9  * 4(t0)
        sw s9,  10 * 4(t0)
        sw s10, 11 * 4(t0)
        sw s11, 12 * 4(t0)

        lw ra,  0  * 4(t1)
        lw s0,  1  * 4(t1)
        lw s1,  2  * 4(t1)
        lw s2,  3  * 4(t1)
        lw s3,  4  * 4(t1)
        lw s4,  5  * 4(t1)
        lw s5,  6  * 4(t1)
        lw s6,  7  * 4(t1)
        lw s7,  8  * 4(t1)
        lw s8,  9  * 4(t1)
        lw s9,  10 * 4(t1)
        lw s10, 11 * 4(t1)
        lw s11, 12 * 4(t1)
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