const Terminal = @import("Terminal.zig");
const isr = @import("../system/isr.zig");
const Port = @import("../utils.zig").Port;

var tick: u32 = 0;

fn handler(_: isr.Registers) void {
    tick += 1;
    Terminal.write("Tick: ");
    Terminal.write_dec(tick);
    Terminal.write("\n");
}

pub fn init(frequency: u32) void {
    isr.set_handler(isr.IRQ0, handler);
    const divisor = 1193180 / frequency;
    Port(u8).init(0x43).write(0x36);
    Port(u8).init(0x40).write(@truncate(u8, divisor));
    Port(u8).init(0x40).write(@truncate(u8, (divisor >> 8)));
}
