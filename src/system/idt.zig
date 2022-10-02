const Terminal = @import("../common/Terminal.zig");
const lidt = @import("../arch/x86/asm.zig").lidt;

// https://wiki.osdev.org/Security#Rings
const Ring = enum(u2) {
    zero,
    one,
    two,
    three,
};

// https://wiki.osdev.org/Segment_Selector
const SegmentSelector = packed struct {
    ring: Ring,
    table: enum(u1) {
        gdt,
        ldt,
    },
    index: u13,
};

// https://wiki.osdev.org/Interrupt_Descriptor_Table#Structure_on_IA-32
const Options = packed struct {
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
};

const Entry = packed struct {
    pointer_low: u16,
    selector: SegmentSelector,
    zero: u8,
    options: Options,
    pointer_high: u16,

    fn init() Entry {
        return .{
            .pointer_low = 0,
            .selector = SegmentSelector{
                .ring = .zero,
                .table = .gdt,
                .index = 0,
            },
            .zero = 0,
            .options = Options{
                .gate_type = .interrupt_gate_32,
                .zero = 0,
                .dpl = .zero,
                .present = false,
            },
            .pointer_high = 0,
        };
    }

    pub fn setHandler(self: *Entry, pointer: fn () void) void {
        // TODO: set selector to segmentation::cs()
        const addr = @ptrToInt(pointer);
        self.*.options.present = true;
        self.*.pointer_low = @truncate(u16, addr);
        self.*.pointer_high = @truncate(u16, addr >> 16);
    }
};

const Register = packed struct {
    limit: u16,
    base: *[256]Entry,

    fn init(table: *[256]Entry) Register {
        return .{
            .limit = @as(u16, @sizeOf(@TypeOf(table.*))),
            .base = table,
        };
    }
};

var idt_table: [256]Entry = undefined;
const idt_register = Register.init(&idt_table);

pub fn init() void {
    idt_table[0] = Entry.init();
    idt_table[0].setHandler(divide_by_zero);
    lidt(@ptrToInt(&idt_register));
}

// Exceptions
fn divide_by_zero() void {
    Terminal.write("DIVIDE BY ZERO OCCURED");
}
