/* entry point is the boot function */
ENTRY(boot)

_sdata = ADDR(.data);
_edata = ADDR(.data) + SIZEOF(.data);
_sidata = LOADADDR(.data);

SECTIONS {
    /* base address */
    . = 0x80200000;

    /* contains the instructions */
    .text :{
        /* .text.boot always placed at the beginning */
        /* KEEP to not discard section */
        KEEP(*(.text.boot));
        /* match all input files with all .text and all .text.* sections */
        ,*(.text .text.*);
    }

    /* contains read-only data */
    .rodata : ALIGN(4) {
        ,*(.rodata .rodata.*);
    }

    /* contains read/write data */
    /* adjust current address to a 4-byte boundary */
    .data : ALIGN(4) {
        ,*(.data .data.*);
    }

    /* contains read/write data with an initial value of zero */
    /* adjust current address to a 4-byte boundary */
    .bss : ALIGN(4) {
        /* assign current address to the symbol '__bss' */
        /* you can access this symbol in C using 'extern char __bss;' */
        __bss = .;
        ,*(.bss .bss.* .sbss .sbss.*);
        __bss_end = .;
    }

    /* kernel stack right after .bss and with size 128KB */
    /* adjust current address to a 4-byte boundary */
    . = ALIGN(4);
    . += 128 * 1024; /* 128KB */
    __stack_top = .;

    . = ALIGN(4096);
    __free_ram = .;
    . += 64 * 1024 * 1024; /* 64MB */
    __free_ram_end = .;
}