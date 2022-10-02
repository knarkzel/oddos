pub inline fn hlt() void {
    asm volatile ("hlt");
}

pub inline fn inb(port: u16) u8 {
    return asm volatile ("inb %[port], %[result]"
        : [result] "={al}" (-> u8),
        : [port] "N{dx}" (port),
    );
}

pub inline fn outb(port: u16, value: u8) void {
    asm volatile ("outb %[value], %[port]"
        :
        : [port] "N{dx}" (port),
          [value] "{al}" (value),
    );
}

pub inline fn lidt(idt_table: usize) void {
    asm volatile ("lidt (%[idt_table])"
        :
        : [idt_table] "r" (idt_table),
    );
}

pub inline fn lgdt(gdt_table: usize) void {
    asm volatile ("lgdt (%[gdt_table])"
        :
        : [gdt_table] "r" (gdt_table),
    );
}
