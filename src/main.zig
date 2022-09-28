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
    @call(.{ .stack = stack_bytes_slice }, main, .{});
    while (true) {}
}

pub fn panic(msg: []const u8, _: ?*std.builtin.StackTrace) noreturn {
    @setCold(true);
    Terminal.write("[kernel panic]: ");
    Terminal.write(msg);
    while (true) {}
}

fn main() void {
    Terminal.initialize();
    Terminal.setColor(.Green, .Black);
    Terminal.write("[oddos]\n\n");
    Terminal.setColor(.LightBlue, .Black);
    Terminal.write("> ");
    Terminal.setColor(.White, .Black);
    Terminal.moveCursor(2, 2);
}
