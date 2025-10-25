#!/bin/sh

set -e

(
  cd ..
  c3c build
  riscv32-unknown-elf-ld -T scripts/linker.ld build/obj/elf-riscv32/*.o -o build/ccco.elf
)