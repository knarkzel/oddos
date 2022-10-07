.type load_gdt, @function
.global load_gdt

load_gdt:
	mov +4(%esp), %eax          // Fetch the gdt register
	lgdt (%eax)                 // Load the new GDT
    ljmp $0x08, $reload_segments // Reload segments

reload_segments:
    mov $0x10, %ax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs
	mov %ax, %ss
    ret

.type load_idt, @function
.global load_idt
    
load_idt:
    mov +4(%esp), %eax // Fetch the idt register
    lidt (%eax)        // Load the new IDT
    ret
