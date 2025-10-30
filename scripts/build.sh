#!/bin/sh

rm -rf ../build/obj

set -e

(
  cd ..
  c3c build --no-entry --riscv-cpu=rvimac
  #riscv32-unknown-elf-as -march=rv32imac -mabi=ilp32 -o build/obj/elf-riscv32/errno.o src/asm/errno.S
  #riscv32-unknown-elf-as -march=rv32imac -mabi=ilp32 -o build/obj/elf-riscv32/sqrt.o src/asm/sqrt.S
  #riscv32-unknown-elf-as -march=rv32imac -mabi=ilp32 -o build/obj/elf-riscv32/sqrtf.o src/asm/sqrtf.S
  /home/blallo/riscv/bin/ld.lld -T scripts/linker.ld -L /home/blallo/riscv/lib/linux -lclang_rt.builtins-riscv32 build/obj/elf-riscv32/*.o -o build/ccco.elf
)
