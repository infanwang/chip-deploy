OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    ROM (rx) : ORIGIN = 0x00000000, LENGTH = 4K
    RAM (rw) : ORIGIN = 0x50000000, LENGTH = 1K
}

SECTIONS
{
    .text : { *(.text.start) *(.text) *(.text.*) } > ROM
    .rodata : { *(.rodata) *(.rodata.*) } > ROM
    _stack_top = 0x50000400;
}
