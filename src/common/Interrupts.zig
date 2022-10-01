const Terminal = @import("Terminal.zig");
const lidt = @import("../arch/x86/asm.zig").lidt;

const Ring = enum(u2) {
    zero,
    one,
    two,
    three,
};

const Table = enum(u1) {
    gdt,
    ldt,
};

// https://wiki.osdev.org/Segment_Selector
fn selector(index: u16, table: Table, ring: Ring) u16 {
    return (index << 3 | @enumToInt(table) << 2 | @enumToInt(ring));
}

// https://wiki.osdev.org/Interrupt_Descriptor_Table#Structure_on_IA-32
const IdtOptions = packed struct {
    gate_type: enum(u4) {
        task_gate = 0x5,
        interrupt_gate_16 = 0x6,
        trap_gate_16 = 0x7,
        interrupt_gate_32 = 0xE,
        trap_gate_32 = 0xF,
    },
    zero: u1,
    dpl: Ring,
    present: bool,

    fn init() IdtOptions {
        return .{
            .gate_type = .interrupt_gate_32,
            .zero = 0,
            .dpl = .zero,
            .present = false,
        };
    }
};

const IdtEntry = packed struct {
    pointer_low: u16,
    selector: u16,
    zero: u8,
    options: IdtOptions,
    pointer_high: u16,

    fn init() IdtEntry {
        return .{
            .pointer_low = 0,
            .selector = selector(0, .zero),
            .zero = 0,
            .options = IdtOptions.init(),
            .pointer_high = 0,
        };
    }

    pub fn setHandler(self: *IdtEntry, pointer: fn () void) void {
        // TODO: set selector to segmentation::cs()
        const addr = @ptrToInt(pointer);
        self.*.options.present = true;
        self.*.pointer_low = @truncate(u16, addr);
        self.*.pointer_high = @truncate(u16, addr >> 16);
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
    idt_table[0] = IdtEntry.init();
    idt_table[0].setHandler(divide_by_zero);
    lidt(@ptrToInt(&idt_register));
}

// Exceptions
fn divide_by_zero() void {
    Terminal.write("DIVIDE BY ZERO OCCURED");
    while (true) {}
}
