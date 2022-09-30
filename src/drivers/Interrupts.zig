const x86 = @import("../x86.zig");
const Terminal = @import("Terminal.zig");

// https://wiki.osdev.org/Interrupt_Descriptor_Table#Structure_on_IA-32
// https://wiki.osdev.org/Segment_Selector
const IdtEntry = packed struct {
    pointer_low: u16,
    selector: u16,
    zero: u8,
    options: u8,
    pointer_high: u32,

    fn init() IdtEntry {
        return .{
            .pointer_low = 0,
            .selector = 0x08,
            .zero = 0,
            .pointer_high = 0,
            .options = 0,
        };
    }

    pub fn withHandler(pointer: fn () void) IdtEntry {
        var entry = IdtEntry.init();
        const addr = @ptrToInt(pointer);
        entry.pointer_low = @truncate(u16, addr);
        entry.pointer_high = @truncate(u16, addr >> 16);
        return entry;
    }
};

// IDT descriptor register pointing at the IDT.
const IdtRegister = packed struct {
    limit: u16,
    base: *[256]IdtEntry,

    fn init(table: *[256]IdtEntry) IdtRegister {
        return .{
            .limit = @as(u16, @sizeOf(@TypeOf(table.*))),
            .base = table,
        };
    }
};

// Interrupt Descriptor Table and Register
var idt_table: [256]IdtEntry = undefined;
var idt_register = IdtRegister.init(&idt_table);

pub fn init() void {
    idt_table[0] = IdtEntry.withHandler(divide_by_zero);
    x86.lidt(@ptrToInt(&idt_register));
}

// Exceptions
fn divide_by_zero() void {
    Terminal.write("DIVIDE BY ZERO OCCURED");
}
