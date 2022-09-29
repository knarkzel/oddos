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

// Entry for exceptions
pub const Entry = struct {
    const Options = packed struct {
        index: u8,
        enable_interrupts: bool,
        must_be_one: u3,
        must_be_zero: u1,
        privilege_level: u2,
        present: bool,

        // Creates a minimal options field with all the must-be-one bits set
        fn init() Options {
            return @bitCast(Options, 0b1110_0000_0000);
        }
    };

    pointer_low: u16,
    gdt_selector: u16,
    options: Options,
    pointer_middle: u16,
    pointer_high: u32,
    reserved: u32,

    // Creates a non-present IDT entry (but sets the must-be-one bits)
    fn init() Entry {
        return .{
            .gdt_selector = 0,
            .pointer_low = 0,
            .pointer_middle = 0,
            .pointer_high = 0,
            .reserved = 0,
            .options = Options.init(),
        };
    }

    /// Set the handler address for the IDT entry and sets the present bit.
    ///
    /// For the code selector field, this function uses the code segment selector currently
    /// active in the CPU.
    fn setHandlerAddr(self: *Entry, addr: u64) void {
        self.pointer_low.* = @truncate(u16, addr);
        self.pointer_middle.* = @truncate(u16, addr >> 16);
        self.pointer_high.* = @truncate(u16, addr >> 32);
        // TODO: self.gdt_selector = segmentation::cs().0;
        self.options.present = true;
    }
};
