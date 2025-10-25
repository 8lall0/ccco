#!/bin/sh

set -e

qemu-system-riscv32 \
  -machine virt \
  -bios default \
  -nographic \
  -serial mon:stdio \
  -no-reboot \
  -kernel ../build/ccco.elf