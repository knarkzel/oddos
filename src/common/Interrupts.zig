const Terminal = @import("Terminal.zig");
const lidt = @import("../arch/x86/asm.zig").lidt;

// https://wiki.osdev.org/Interrupt_Descriptor_Table#Structure_on_IA-32
const IdtOptions = packed struct {
    gate_type: enum(u4) {
        task_gate = 0x5,
        interrupt_gate_16 = 0x6,
        trap_gate_16 = 0x7,
        interrupt_gate_32 = 0xE,
        trap_gate_32 = 0xE,
    },
    zero: u1 = 0,
    dpl: u2,
    present: u1,
};

// https://wiki.osdev.org/Segment_Selector
const IdtEntry = packed struct {
    pointer_low: u16,
    selector: u16,
    zero: u8,
    options: u8,
    pointer_high: u16,

    fn init() IdtEntry {
        return .{
            .pointer_low = 0,
            .selector = 0x08,
            .zero = 0,
            .pointer_high = 0,
            .options = 0,
        };
    }

    pub fn withHandler(pointer: fn () noreturn) IdtEntry {
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
    lidt(@ptrToInt(&idt_register));
}

// Exceptions
fn divide_by_zero() noreturn {
    Terminal.write("DIVIDE BY ZERO OCCURED");
    while (true) {}
}
