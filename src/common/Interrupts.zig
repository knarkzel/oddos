const Terminal = @import("Terminal.zig");
const lidt = @import("../arch/x86/asm.zig").lidt;

const Ring = enum(u4) {
    zero,
    one,
    two,
    three,
};

// Create a new SegmentSelector where index is index in GDT or LDT array
fn selector(index: u16, ring: Ring) u16 {
    return (index << 3 | @enumToInt(ring));
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
    dpl: u2,
    present: u1,

    fn init() IdtOptions {
        return .{
            .gate_type = .interrupt_gate_32,
            .zero = 0,
            .dpl = 0,
            .present = 1,
        };
    }
};

// https://wiki.osdev.org/Segment_Selector
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

    pub fn setHandler(self: *IdtEntry, pointer: fn () noreturn) void {
        // TODO: set selector to segmentation::cs()
        const addr = @ptrToInt(pointer);
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
            .limit = @as(u16, @sizeOf(@TypeOf(table.*))) - 1,
            .base = table,
        };
    }
};

// Interrupt Descriptor Table and Register
var idt_table: [256]IdtEntry = undefined;
var idt_register = IdtRegister.init(&idt_table);

pub fn init() void {
    idt_table[0] = blk: {
        var entry = IdtEntry.init();
        entry.setHandler(divide_by_zero);
        break :blk entry;
    };
    lidt(@ptrToInt(&idt_register));
}

// Exceptions
fn divide_by_zero() noreturn {
    Terminal.write("DIVIDE BY ZERO OCCURED");
    while (true) {}
}
