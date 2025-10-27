#!/bin/sh

rm -rf ../build/obj

set -e

(
  cd ..
  c3c build --no-entry --riscv-cpu=rvimac
  /opt/riscv/bin/ld.lld -T scripts/linker.ld build/obj/elf-riscv32/*.o -o build/ccco.elf
)
