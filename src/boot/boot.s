
.section .text
.code32
.global _start

_start:
    mov esp, stack_top
    mov dword ptr [0xb8000], 0x0f4b0f4f
    call check_multiboot
    call check_cpuid
    call check_long_mode
    jmp _init

check_multiboot:
    cmp eax, 0x36d76289
    jne .no_multiboot
    ret
    .no_multiboot:
    mov al, '0'
    jmp error

check_cpuid:
    // https://wiki.osdev.org/Setting_Up_Long_Mode#Detection_of_CPUID
    // Check if CPUID is supported by attempting to flip the ID bit (bit 21)
    // in the FLAGS register. If we can flip it, CPUID is available.
    pushfd                  // Copy FLAGS in to EAX via stack
    pop eax
    mov ecx, eax            // Copy to ECX as well for comparing later on
    xor eax, 1 << 21        // Flip the ID bit
    push eax                // Copy EAX to FLAGS via the stack
    popfd
    pushfd                  // Copy FLAGS back to EAX (with the flipped bit if CPUID is supported)
    pop eax
    push ecx                // Restore FLAGS from the old version stored in ECX
    popfd
    cmp eax, ecx            // Compare EAX and ECX. If they are equal then that means the bit wasn't flipped, and CPUID isn't supported.
    je .no_cpuid
    ret
    .no_cpuid:
    mov al, '1'
    jmp error

check_long_mode:
    // test if extended processor info in available
    mov eax, 0x80000000    // implicit argument for cpuid
    cpuid                  // get highest supported argument
    cmp eax, 0x80000001    // it needs to be at least 0x80000001
    jb .no_long_mode       // if it's less, the CPU is too old for long mode
    // use extended info to test if long mode is available
    mov eax, 0x80000001    // argument for extended processor info
    cpuid                  // returns various feature bits in ecx and edx
    test edx, 1 << 29      // test if the LM-bit is set in the D-register
    jz .no_long_mode       // If it's not set, there is no long mode
    ret
    .no_long_mode:
    mov al, '2'
    jmp error

// Prints `ERR: ` and the given error code to screen and hangs.
// parameter: error code (in ascii) in al
error:
    mov dword ptr [0xb8000], 0x4f524f45
    mov dword ptr [0xb8004], 0x4f3a4f52
    mov dword ptr [0xb8008], 0x4f204f20
    mov byte  ptr [0xb800a], al
    hlt

print:
    cld                     // set direction flag to increment
    mov edi, 0xb8000        // Set destination index to the VGA buffer
    mov esi, hello_world

    .loop:
    mov ah, 0x4f            // Set the attributes to white-on-black
    mov al, [esi]           // Load the next character from the string
    stosw                   // Write the ax register to the VGA buffer
    inc esi                 // Increment the source index

    cmp al, 0               // Check if we've reached the end of the string
    loop .loop              // If not, loop

    hlt
    ret

.section .rodata
hello_world:
    .ascii "Hello, world!\0"

.section .bss
stack_bottom:
    .space 64
stack_top:
