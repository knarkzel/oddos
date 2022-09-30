pub inline fn hlt() void {
    asm volatile ("hlt");
}

pub inline fn lidt(idt_table: usize) void {
    asm volatile ("lidt (%[idt_table])"
        :
        : [idt_table] "r" (idt_table)
    );
}
