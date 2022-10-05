const std = @import("std");

// These extern directives lets us access the address of our ASM ISR handlers
extern fn isr0() void;
extern fn isr1() void;
extern fn isr2() void;
extern fn isr3() void;
extern fn isr4() void;
extern fn isr5() void;
extern fn isr6() void;
extern fn isr7() void;
extern fn isr8() void;
extern fn isr9() void;
extern fn isr10() void;
extern fn isr11() void;
extern fn isr12() void;
extern fn isr13() void;
extern fn isr14() void;
extern fn isr15() void;
extern fn isr16() void;
extern fn isr17() void;
extern fn isr18() void;
extern fn isr19() void;
extern fn isr20() void;
extern fn isr21() void;
extern fn isr22() void;
extern fn isr23() void;
extern fn isr24() void;
extern fn isr25() void;
extern fn isr26() void;
extern fn isr27() void;
extern fn isr28() void;
extern fn isr29() void;
extern fn isr30() void;
extern fn isr31() void;

// https://wiki.osdev.org/Interrupt_Descriptor_Table#Gate_Descriptor
const GateDescriptor = packed struct {
    offset_low: u16,
    segment_selector: u16,
    zero: u8,
    flags: u8,
    offset_high: u16,

    fn init(offset: u32, segment_selector: u16, flags: u8) GateDescriptor {
        return .{
            .offset_low = @truncate(u16, offset & 0xFFFF),
            .offset_high = @truncate(u16, (offset >> 16) & 0xFFFF),
            .segment_selector = segment_selector,
            .zero = 0,
            .flags = flags,
        };
    }
};

const InterruptDescriptorRegister = packed struct {
    limit: u16,
    base: *[256]GateDescriptor,

    fn init(table: *[256]GateDescriptor) InterruptDescriptorRegister {
        return .{
            .limit = @as(u16, @sizeOf(@TypeOf(table.*))) - 1,
            .base = table,
        };
    }
};

extern fn load_idt(register: *const InterruptDescriptorRegister) void;

var idt_table: [256]GateDescriptor = undefined;
var idt_register: InterruptDescriptorRegister = undefined;

pub fn init() void {
    idt_table[0] = GateDescriptor.init(@ptrToInt(isr0), 0x08, 0x8E);
    idt_table[1] = GateDescriptor.init(@ptrToInt(isr1), 0x08, 0x8E);
    idt_table[2] = GateDescriptor.init(@ptrToInt(isr2), 0x08, 0x8E);
    idt_table[3] = GateDescriptor.init(@ptrToInt(isr3), 0x08, 0x8E);
    idt_table[4] = GateDescriptor.init(@ptrToInt(isr4), 0x08, 0x8E);
    idt_table[5] = GateDescriptor.init(@ptrToInt(isr5), 0x08, 0x8E);
    idt_table[6] = GateDescriptor.init(@ptrToInt(isr6), 0x08, 0x8E);
    idt_table[7] = GateDescriptor.init(@ptrToInt(isr7), 0x08, 0x8E);
    idt_table[8] = GateDescriptor.init(@ptrToInt(isr8), 0x08, 0x8E);
    idt_table[9] = GateDescriptor.init(@ptrToInt(isr9), 0x08, 0x8E);
    idt_table[10] = GateDescriptor.init(@ptrToInt(isr10), 0x08, 0x8E);
    idt_table[11] = GateDescriptor.init(@ptrToInt(isr11), 0x08, 0x8E);
    idt_table[12] = GateDescriptor.init(@ptrToInt(isr12), 0x08, 0x8E);
    idt_table[13] = GateDescriptor.init(@ptrToInt(isr13), 0x08, 0x8E);
    idt_table[14] = GateDescriptor.init(@ptrToInt(isr14), 0x08, 0x8E);
    idt_table[15] = GateDescriptor.init(@ptrToInt(isr15), 0x08, 0x8E);
    idt_table[16] = GateDescriptor.init(@ptrToInt(isr16), 0x08, 0x8E);
    idt_table[17] = GateDescriptor.init(@ptrToInt(isr17), 0x08, 0x8E);
    idt_table[18] = GateDescriptor.init(@ptrToInt(isr18), 0x08, 0x8E);
    idt_table[19] = GateDescriptor.init(@ptrToInt(isr19), 0x08, 0x8E);
    idt_table[20] = GateDescriptor.init(@ptrToInt(isr20), 0x08, 0x8E);
    idt_table[21] = GateDescriptor.init(@ptrToInt(isr21), 0x08, 0x8E);
    idt_table[22] = GateDescriptor.init(@ptrToInt(isr22), 0x08, 0x8E);
    idt_table[23] = GateDescriptor.init(@ptrToInt(isr23), 0x08, 0x8E);
    idt_table[24] = GateDescriptor.init(@ptrToInt(isr24), 0x08, 0x8E);
    idt_table[25] = GateDescriptor.init(@ptrToInt(isr25), 0x08, 0x8E);
    idt_table[26] = GateDescriptor.init(@ptrToInt(isr26), 0x08, 0x8E);
    idt_table[27] = GateDescriptor.init(@ptrToInt(isr27), 0x08, 0x8E);
    idt_table[28] = GateDescriptor.init(@ptrToInt(isr28), 0x08, 0x8E);
    idt_table[29] = GateDescriptor.init(@ptrToInt(isr29), 0x08, 0x8E);
    idt_table[30] = GateDescriptor.init(@ptrToInt(isr30), 0x08, 0x8E);
    idt_table[31] = GateDescriptor.init(@ptrToInt(isr31), 0x08, 0x8E);

    // Load idt
    idt_register = InterruptDescriptorRegister.init(&idt_table);
    load_idt(&idt_register);
}
