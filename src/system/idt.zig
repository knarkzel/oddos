const std = @import("std");
const fieldInfo = std.meta.fieldInfo;
const lidt = @import("../arch/x86/asm.zig").lidt;
const Terminal = @import("../driver/Terminal.zig");

// https://wiki.osdev.org/Interrupt_Descriptor_Table#Gate_Descriptor
const GateDescriptor = packed struct {
    offset_low: u16,
    segment_selector: packed struct {
        privilege: enum(u2) {
            zero,
            one,
            two,
            three,
        },
        table: enum(u1) {
            gdt,
            ldt,
        },
        index: u13,
    },
    reserved: u8,
    options: packed struct {
        gate_type: enum(u4) {
            task_gate = 0x5,
            interrupt_gate_16 = 0x6,
            trap_gate_16 = 0x7,
            interrupt_gate_32 = 0xE,
            trap_gate_32 = 0xF,
        },
        reserved: u1,
        privilege: enum(u2) {
            zero,
            one,
            two,
            three,
        },
        present: bool,
    },
    offset_high: u16,

    fn init() GateDescriptor {
        return .{
            .offset_low = 0,
            .segment_selector = .{
                .privilege = .zero,
                .table = .gdt,
                .index = 0,
            },
            .reserved = 0,
            .options = .{
                .gate_type = .trap_gate_32,
                .reserved = 0,
                .privilege = .zero,
                .present = false,
            },
            .offset_high = 0,
        };
    }

    pub fn setException(self: *GateDescriptor, handler: fn () callconv(.Interrupt) void) void {
        const offset = @ptrToInt(handler);
        self.*.options.present = true;
        self.*.offset_low = @truncate(u16, offset);
        self.*.offset_high = @truncate(u16, offset >> 16);
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

var idt_table: [256]GateDescriptor = undefined;
var idt_register: InterruptDescriptorRegister = undefined;

pub fn init() void {
    idt_table[0] = GateDescriptor.init();
    idt_table[0].setException(divide_by_zero);
    idt_register = InterruptDescriptorRegister.init(&idt_table);
    lidt(@ptrToInt(&idt_register));
}

// Exceptions
fn divide_by_zero() callconv(.Interrupt) void {
    Terminal.write("DIVIDE BY ZERO OCCURED");
}
