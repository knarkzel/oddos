const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;

var row: usize = 0;
var column: usize = 0;
var color = vgaEntryColor(.White, .Black);
const buffer = @intToPtr([*]volatile u16, 0xB8000);

pub const VgaColor = enum(u8) {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGrey = 7,
    DarkGrey = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightMagenta = 13,
    LightBrown = 14,
    White = 15,
};

pub fn initialize() void {
    var y: usize = 0;
    while (y < VGA_HEIGHT) : (y += 1) {
        var x: usize = 0;
        while (x < VGA_WIDTH) : (x += 1) {
            putCharAt(' ', color, x, y);
        }
    }
}

pub fn write(data: []const u8) void {
    for (data) |c|
        if (c == '\n') {
            column = 0;
            row += 1;
        } else putChar(c);
    moveCursor(@intCast(u16, column), @intCast(u16, row));
}

pub fn vgaEntryColor(fg: VgaColor, bg: VgaColor) u8 {
    return @enumToInt(fg) | (@enumToInt(bg) << 4);
}

pub fn setColor(fg: VgaColor, bg: VgaColor) void {
    color = vgaEntryColor(fg, bg);
}

pub fn disableCursor() void {
    outb(0x3D4, 0x0A);
    outb(0x3D5, 0x20);
}

pub fn moveCursor(x: u16, y: u16) void {
    const position = y * VGA_WIDTH + x;
    outb(0x3D4, 0x0F);
    outb(0x3D5, @intCast(u8, (position & 0xFF)));
    outb(0x3D4, 0x0E);
    outb(0x3D5, @intCast(u8, (position >> 8) & 0xFF));
}

fn outb(port: u16, value: u8) void {
    asm volatile ("outb %[value], %[port]"
        :
        : [port] "N{dx}" (port),
          [value] "{al}" (value),
    );
}

fn vgaEntry(uc: u8, new_color: u8) u16 {
    return uc | (@as(u16, new_color) << 8);
}

fn putCharAt(c: u8, new_color: u8, x: usize, y: usize) void {
    const index = y * VGA_WIDTH + x;
    buffer[index] = vgaEntry(c, new_color);
}

fn putChar(c: u8) void {
    putCharAt(c, color, column, row);
    column += 1;
    if (column == VGA_WIDTH) {
        column = 0;
        row += 1;
        if (row == VGA_HEIGHT)
            row = 0;
    }
}
