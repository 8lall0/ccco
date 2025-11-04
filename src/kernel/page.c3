module kernel::page;

import kernel::types;
import kernel;

const PAGE_SIZE = 4096;
const PAGE_V = (1 << 0); // "Valid" bit (entry is enabled)
const PAGE_R = (1 << 1); // Readable
const PAGE_W = (1 << 2); // Writable
const PAGE_X = (1 << 3); // Executable
const PAGE_U = (1 << 4);

const SATP_SV32 = (1u << 31);

fn void map_page(Uint32_t *table1, Uint32_t vaddr, Paddr_t paddr, Uint32_t flags) {
    if ($alignof(vaddr) == PAGE_SIZE) {
        kernel::_panic("unaligned vaddr");
    }

    if ($alignof(paddr) == PAGE_SIZE) {
        kernel::_panic("unaligned paddr");
    }

    Uint32_t vpn1 = (vaddr >> 22) & 0x3ff;
    if ((table1[vpn1] & PAGE_V) == 0) {
        // Create the 1st level page table if it doesn't exist.
        Uint32_t pt_paddr = kernel::alloc_pages(1);
        table1[vpn1] = ((pt_paddr / PAGE_SIZE) << 10) | PAGE_V;
    }

    // Set the 2nd level page table entry to map the physical page.
    Uint32_t vpn0 = (vaddr >> 12) & 0x3ff;
    Uint32_t *table0 = (Uint32_t *) ((table1[vpn1] >> 10) * PAGE_SIZE);
    table0[vpn0] = ((paddr / PAGE_SIZE) << 10) | flags | PAGE_V;
}