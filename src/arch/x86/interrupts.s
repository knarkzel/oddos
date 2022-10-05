.macro isr_generate n
    .align 4
    .type isr\n, @function
    .global isr\n

    isr\n:
        cli 
        // Push a dummy error code for interrupts that don't have one
        .if (\n != 8 && !(\n >= 10 && \n <= 14) && \n != 17)
            push $0
        .endif
        push $\n
        jmp isr_common_stub
.endmacro

.extern isr_handler
    
isr_common_stub:
    pusha            // Pushes edi, esi, ebp, esp, ebx, edx, ecx, eax

    mov %ds, %ax     // Lower 16-bits of eax = ds
    push %eax        // Save the data segment descriptor

    mov 0x10, %ax    // Load the kernel data segment descriptor
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs

    call isr_handler

    pop %eax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %gs, %ax

    popa             // Pops edi, esi, ebp, esp, ebx, edx, ecx, eax
    add 0x8, %esp    // Cleans up the pushed error code and pushed ISR number
    sti
    iret             // Pops cs, eip, eflags, ss, and esp
    
// Exceptions
isr_generate 0
isr_generate 1
isr_generate 2
isr_generate 3
isr_generate 4
isr_generate 5
isr_generate 6
isr_generate 7
isr_generate 8
isr_generate 9
isr_generate 10
isr_generate 11
isr_generate 12
isr_generate 13
isr_generate 14
isr_generate 15
isr_generate 16
isr_generate 17
isr_generate 18
isr_generate 19
isr_generate 20
isr_generate 21
isr_generate 22
isr_generate 23
isr_generate 24
isr_generate 25
isr_generate 26
isr_generate 27
isr_generate 28
isr_generate 29
isr_generate 30
isr_generate 31
