const std = @import("std");
const fieldInfo = std.meta.fieldInfo;
const lgdt = @import("../arch/x86/asm.zig").lgdt;

// https://wiki.osdev.org/GDT#Segment_Descriptor
const SegmentDescriptor = packed struct {
    limit_low: u16,
    base_low: u24,
    access_byte: packed struct {
        accessed: bool,
        readable_writeable: packed union {
            data: enum(u1) {
                disable_write,
                enable_write,
            },
            code: enum(u1) {
                disable_read,
                enable_read,
            },
        },
        direction_conforming: packed union {
            data: enum(u1) {
                grows_up,
                grows_down,
            },
            code: enum(u1) {
                current_privilege,
                equal_or_lower_privilege,
            },
        },
        executable: enum(u1) {
            data,
            code,
        },
        descriptor: enum(u1) {
            system_segment,
            code_or_data,
        },
        privilege: enum(u2) {
            zero,
            one,
            two,
            three,
        },
        present: bool,
    },
    limit_high: u4,
    flags: packed struct {
        reserved: u1,
        long_mode: enum(u1) {
            other,
            code_segment_64,
        },
        size: enum(u1) {
            protected_mode_segment_16,
            protected_mode_segment_32,
        },
        granularity: enum(u1) {
            byte,
            page,
        },
    },
    base_high: u8,

    fn init(base: u32, limit: u20, access_byte: u8, flags: u4) SegmentDescriptor {
        return .{
            .limit_low = @truncate(u16, limit),
            .base_low = @truncate(u24, base),
            .access_byte = @bitCast(fieldInfo(SegmentDescriptor, .access_byte).field_type, access_byte),
            .limit_high = @truncate(u4, limit >> 16),
            .flags = @bitCast(fieldInfo(SegmentDescriptor, .flags).field_type, flags),
            .base_high = @truncate(u8, base >> 24),
        };
    }
};

const SystemSegmentDescriptor = packed struct {
    @"type": enum(u4) {
        tss_available_16 = 0x1,
        ldt = 0x2,
        tss_busy_16 = 0x3,
        tss_available_32 = 0x9,
        tss_busy_32 = 0xB,
    },
    descriptor: enum(u1) {
        system_segment,
        code_or_data,
    },
    privilege: enum(u2) {
        zero,
        one,
        two,
        three,
    },
    present: bool,

    fn init(access_byte: u8) SystemSegmentDescriptor {
        return @bitCast(SystemSegmentDescriptor, access_byte);
    }
};

const GlobalDescriptorRegister = packed struct {
    limit: u16,
    base: *[5]SegmentDescriptor,

    fn init(table: *[5]SegmentDescriptor) GlobalDescriptorRegister {
        return .{
            .limit = @as(u16, @sizeOf(@TypeOf(table.*))) - 1,
            .base = table,
        };
    }
};

var gdt_table: [5]SegmentDescriptor = undefined;
var gdt_register: GlobalDescriptorRegister = undefined;

pub fn init() void {
    gdt_table = [5]SegmentDescriptor{
        SegmentDescriptor.init(0, 0x00000, 0x00, 0x0), // Null Descriptor
        SegmentDescriptor.init(0, 0xFFFFF, 0x9A, 0xC), // Kernel Mode Code Segment
        SegmentDescriptor.init(0, 0xFFFFF, 0x92, 0xC), // Kernel Mode Data Segment
        SegmentDescriptor.init(0, 0xFFFFF, 0xFA, 0xC), // User Mode Code Segment
        SegmentDescriptor.init(0, 0xFFFFF, 0xF2, 0xC), // User Mode Data Segment
    };
    gdt_register = GlobalDescriptorRegister.init(&gdt_table);
    lgdt(@ptrToInt(&gdt_register));
}
