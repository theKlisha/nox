ENTRY(_start)

SECTIONS {
    .multiboot_header : ALIGN(4) {
        KEEP(*(.multiboot_header))
    }

    .text : ALIGN(4K) {
        *(.text)
    }

    .rodata : ALIGN(4K) {
        *(.rodata)
    }

    .data : ALIGN(4K) {
        *(.data)
    }

    .bss : ALIGN(4K) {
        *(COMMON)
        *(.bss)
    }

    /DISCARD/ :
    {
        *(.comment);
        *(.symtab);
        *(.strtab);
    }
}
