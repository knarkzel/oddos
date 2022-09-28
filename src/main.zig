const std = @import("std");
const Terminal = @import("drivers/Terminal.zig");

const MultiBoot = packed struct {
    magic: i32,
    flags: i32,
    checksum: i32,
};

const ALIGN = 1 << 0;
const MEMINFO = 1 << 1;
const MAGIC = 0x1BADB002;
const FLAGS = ALIGN | MEMINFO;

export var multiboot align(4) linksection(".multiboot") = MultiBoot{
    .magic = MAGIC,
    .flags = FLAGS,
    .checksum = -(MAGIC + FLAGS),
};

export var stack_bytes: [16 * 1024]u8 align(16) linksection(".bss") = undefined;
const stack_bytes_slice = stack_bytes[0..];

export fn _start() callconv(.Naked) noreturn {
    // Enable interrupts
    // asm volatile ("sti");

    // Call main function
    @call(.{ .stack = stack_bytes_slice }, main, .{});
    while (true)
        asm volatile ("hlt");
}

pub fn panic(msg: []const u8, _: ?*std.builtin.StackTrace) noreturn {
    @setCold(true);
    Terminal.setColor(.Red, .Black);
    Terminal.write("\nKERNEL PANIC: ");
    Terminal.write(msg);
    Terminal.disableCursor();
    while (true)
        asm volatile ("hlt");
}

fn main() void {
    Terminal.initialize();
    Terminal.setColor(.Green, .Black);
    Terminal.write("oddos ");
    Terminal.setColor(.White, .Black);
    Terminal.write("> ");
}
