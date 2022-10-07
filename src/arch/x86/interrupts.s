// Exceptions
.macro isr_generate n
    .type isr\n, @function
    .global isr\n

    isr\n:
        // Push a dummy error code for interrupts that don't have one.
        .if (\n != 8 && !(\n >= 10 && \n <= 14) && \n != 17)
            push $0
        .endif
        push $\n       // Push the interrupt number.
        jmp isr_common  // Jump to the common handler.
.endmacro
    
.extern isr_handler

.type isr_common, @function
    
isr_common:
    pusha            // Pushes edi, esi, ebp, esp, ebx, edx, ecx, eax

    mov %ds, %ax     // Lower 16-bits of eax = ds
    push %eax        // Save the data segment descriptor

    mov $0x10, %ax   // Load the kernel data segment descriptor
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs

    call isr_handler

    pop %eax         // Reload the original data segment descriptor
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs

    popa             // Pops edi, esi, ebp, esp, ebx, edx, ecx, eax
    add 0x8, %esp    // Cleans up the pushed error code and pushed ISR number
    sti
    iret             // Pops cs, eip, eflags, ss, and esp
    
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

// Interrupt request routines
.macro irq_generate index to 
    .type irq\index, @function
    .global irq\index

    irq\index:
        cli
        push $0
        push $\to
        jmp irq_common
.endmacro

.extern irq_handler

.type irq_common, @function
    
irq_common:
    pusha            // Pushes edi, esi, ebp, esp, ebx, edx, ecx, eax

    mov %ds, %ax     // Lower 16-bits of eax = ds
    push %eax        // Save the data segment descriptor

    mov $0x10, %ax   // Load the kernel data segment descriptor
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs

    call irq_handler

    pop %ebx         // Reload the original data segment descriptor
    mov %bx, %ds
    mov %bx, %es
    mov %bx, %fs
    mov %bx, %gs

    popa             // Pops edi, esi, ebp, esp, ebx, edx, ecx, eax
    add $8, %esp     // Cleans up the pushed error code and pushed ISR number
    sti
    iret             // Pops cs, eip, eflags, ss, and esp
    
irq_generate 0 32
irq_generate 1 33
irq_generate 2 34
irq_generate 3 35
irq_generate 4 36
irq_generate 5 37
irq_generate 6 38
irq_generate 7 39
irq_generate 8 40
irq_generate 9 41
irq_generate 10 42
irq_generate 11 43
irq_generate 12 44
irq_generate 13 45
irq_generate 14 46
irq_generate 15 47
