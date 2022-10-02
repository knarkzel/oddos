const std = @import("std");
const main = @import("main.zig");
const hlt = @import("arch/x86/asm.zig").hlt;
const Terminal = @import("driver/Terminal.zig");

const ALIGN = 1 << 0;
const MEMINFO = 1 << 1;
const MAGIC = 0x1BADB002;
const FLAGS = ALIGN | MEMINFO;

const MultiBoot = packed struct {
    magic: i32,
    flags: i32,
    checksum: i32,
};

export var multiboot align(4) linksection(".multiboot") = MultiBoot{
    .magic = MAGIC,
    .flags = FLAGS,
    .checksum = -(MAGIC + FLAGS),
};

export var stack_bytes: [16 * 1024]u8 align(16) linksection(".bss") = undefined;

export fn _start() callconv(.Naked) noreturn {
    main.init();
    @call(.{ .stack = &stack_bytes }, main.main, .{});
    while (true) hlt();
}

pub fn panic(msg: []const u8, _: ?*std.builtin.StackTrace) noreturn {
    @setCold(true);
    Terminal.setColor(.Red, .Black);
    Terminal.write("\nKERNEL PANIC: ");
    Terminal.write(msg);
    Terminal.disableCursor();
    while (true) hlt();
}
