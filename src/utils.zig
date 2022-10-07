const x86 = @import("arch/x86/asm.zig");
const inb = x86.inb;
const outb = x86.outb;

// Ports mainly for IO
pub fn Port(comptime T: type) type {
    return struct {
        port: u16,

        pub fn init(port: u16) @This() {
            return .{
                .port = port,
            };
        }

        pub fn read(self: @This()) T {
            return switch (T) {
                u8 => inb(self.port),
                else => @compileError("No such instruction for type"),
            };
        }

        pub fn write(self: @This(), value: T) void {
            return switch (T) {
                u8 => outb(self.port, value),
                else => @compileError("No such instruction for type"),
            };
        }
    };
}

// Adds delay to IO
pub fn wait() void {
    Port(u8).init(0x80).write(0);
}
