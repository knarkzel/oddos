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

fn inb(port: u16) u8 {
    return asm volatile ("inb %[port], %[result]"
        : [result] "={al}" (-> u8),
        : [port] "N{dx}" (port),
    );
}

fn outb(port: u16, value: u8) void {
    asm volatile ("outb %[value], %[port]"
        :
        : [port] "N{dx}" (port),
          [value] "{al}" (value),
    );
}
