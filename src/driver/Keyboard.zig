const Terminal = @import("Terminal.zig");
const isr = @import("../system/isr.zig");
const Port = @import("../utils.zig").Port;

fn handler(_: isr.Registers) void {
    const scancode = Port(u8).init(0x60).read();
    Terminal.write_hex(scancode);
}

pub fn init() void {
    isr.set_handler(isr.IRQ1, handler);
    Port(u8).init(0x21).write(0xFD);
    Port(u8).init(0xA1).write(0xFF);
}
