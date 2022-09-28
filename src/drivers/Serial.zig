const Port = @import("Port.zig").Port;

const base = 0x3F8;
const data = Port(u8).init(base);
const int_en = Port(u8).init(base + 1);
const fifo_ctrl = Port(u8).init(base + 2);
const line_ctrl = Port(u8).init(base + 3);
const modem_ctrl = Port(u8).init(base + 4);
const line_sts = Port(u8).init(base + 5);
