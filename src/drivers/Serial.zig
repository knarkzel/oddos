const Port = @import("../utils/Port.zig").Port;

const base = 0x3F8;
const data = Port(u8).init(base);
const int_en = Port(u8).init(base + 1);
const fifo_ctrl = Port(u8).init(base + 2);
const line_ctrl = Port(u8).init(base + 3);
const modem_ctrl = Port(u8).init(base + 4);
const line_sts = Port(u8).init(base + 5);

pub fn init() void {
    // Disable interrupts
    int_en.write(0x00);

    // Enable DLAB
    line_ctrl.write(0x80);

    // Set maximum speed to 38400 bps by configuring DLL and DLM
    data.write(0x03);
    int_en.write(0x00);

    // Disable DLAB and set data word length to 8 bits
    line_ctrl.write(0x03);

    // Enable FIFO, clear TX/RX queues and
    // set interrupt watermark at 14 bytes
    fifo_ctrl.write(0xC7);

    // Mark data terminal ready, signal request to send
    // and enable auxilliary output #2 (used as interrupt line for CPU)
    modem_ctrl.write(0x0B);

    // Enable interrupts
    int_en.write(0x01);
}

/// Sends a byte on the serial port
pub fn send(byte: u8) void {
    switch (byte) {
        8 | 0x7F => {
            data.write(8);
            data.write(' ');
            data.write(8);
        },
        else => data.write(byte),
    }
}

/// Sends bytes to the serial port
pub fn write(bytes: []const u8) void {
    for (bytes) |byte|
        send(byte);
}

/// Receives a byte on the serial port
pub fn receive() u8 {
    return data.read();
}
