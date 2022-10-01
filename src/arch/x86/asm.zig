pub inline fn hlt() void {
    asm volatile ("hlt");
}

pub inline fn lidt(idt_table: usize) void {
    asm volatile ("lidt (%[idt_table])"
        :
        : [idt_table] "r" (idt_table),
    );
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
