#!/bin/sh

rm -rf ../build/obj

set -e

(
  cd ..
  c3c build --no-entry
  ld.lld -T scripts/linker.ld -L /opt/riscv/lib/linux -lclang_rt.builtins-riscv32 build/obj/elf-riscv32/*.o -o build/ccco.elf
)
