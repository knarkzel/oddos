const Terminal = @import("Terminal.zig");
const isr = @import("../system/isr.zig");
const Port = @import("../utils.zig").Port;

var lshift = false;

fn handler(_: isr.Registers) void {
    const scancode = Port(u8).init(0x60).read();
    switch (scancode) {
        0x0E => Terminal.delete(),
        0x02...0x0A => Terminal.write_dec(scancode - 0x01),
        0x0B => Terminal.write_dec(0),
        0x10 => if (lshift) Terminal.write("Q") else Terminal.write("q"),
        0x11 => if (lshift) Terminal.write("W") else Terminal.write("w"),
        0x12 => if (lshift) Terminal.write("E") else Terminal.write("e"),
        0x13 => if (lshift) Terminal.write("R") else Terminal.write("r"),
        0x14 => if (lshift) Terminal.write("T") else Terminal.write("t"),
        0x15 => if (lshift) Terminal.write("Y") else Terminal.write("y"),
        0x16 => if (lshift) Terminal.write("U") else Terminal.write("u"),
        0x17 => if (lshift) Terminal.write("I") else Terminal.write("i"),
        0x18 => if (lshift) Terminal.write("O") else Terminal.write("o"),
        0x19 => if (lshift) Terminal.write("P") else Terminal.write("p"),
        0x1E => if (lshift) Terminal.write("A") else Terminal.write("a"),
        0x1F => if (lshift) Terminal.write("S") else Terminal.write("s"),
        0x20 => if (lshift) Terminal.write("D") else Terminal.write("d"),
        0x21 => if (lshift) Terminal.write("F") else Terminal.write("f"),
        0x22 => if (lshift) Terminal.write("G") else Terminal.write("g"),
        0x23 => if (lshift) Terminal.write("H") else Terminal.write("h"),
        0x24 => if (lshift) Terminal.write("J") else Terminal.write("j"),
        0x25 => if (lshift) Terminal.write("K") else Terminal.write("k"),
        0x26 => if (lshift) Terminal.write("L") else Terminal.write("l"),
        0x2C => if (lshift) Terminal.write("Z") else Terminal.write("z"),
        0x2D => if (lshift) Terminal.write("X") else Terminal.write("x"),
        0x2E => if (lshift) Terminal.write("C") else Terminal.write("c"),
        0x2F => if (lshift) Terminal.write("V") else Terminal.write("v"),
        0x30 => if (lshift) Terminal.write("B") else Terminal.write("b"),
        0x31 => if (lshift) Terminal.write("N") else Terminal.write("n"),
        0x32 => if (lshift) Terminal.write("M") else Terminal.write("m"),
        0x39 => Terminal.write(" "),
        0x1C => {
            Terminal.write("\n");
            Terminal.prompt();
        },
        0x2A => lshift = true,
        0xAA => lshift = false,
        else => {
            // Terminal.write("[");
            // Terminal.write_hex(scancode);
            // Terminal.write("]");
        },
    }
}

pub fn init() void {
    isr.set_handler(isr.IRQ1, handler);
    Port(u8).init(0x21).write(0xFD);
    Port(u8).init(0xA1).write(0xFF);
}
