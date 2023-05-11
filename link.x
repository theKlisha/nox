ENTRY(_start);

SECTIONS {
    . = 1M;

    .boot : ALIGN(4) {
        KEEP(*(._multiboot_header));
    }

    .text : ALIGN(4K) {
        KEEP(*(.text._start));
        KEEP(*(.text._init));
        *(.text*);
    }

    .rodata : ALIGN(4K) {
        *(.rodata)
    }

    .data : ALIGN(4K) {
        *(.data)
    }

    .bss : ALIGN(4K) {
        *(COMMON)
        *(.bss);
    }
}
