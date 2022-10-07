const std = @import("std");
const fmt = std.fmt;
const Port = @import("../utils.zig").Port;

// https://wiki.osdev.org/VGA_Hardware
// https://wiki.osdev.org/VGA_Resources
// https://wiki.osdev.org/Drawing_In_a_Linear_Framebuffer
const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;

var row: usize = 0;
var column: usize = 0;
var color = vgaEntryColor(.White, .Black);
const buffer = @intToPtr([*]volatile u16, 0xB8000);
const vga_index = Port(u8).init(0x3D4);
const vga_data = Port(u8).init(0x3D5);

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

pub fn init() void {
    var y: usize = 0;
    while (y < VGA_HEIGHT) : (y += 1) {
        var x: usize = 0;
        while (x < VGA_WIDTH) : (x += 1)
            putCharAt(' ', color, x, y);
    }
}

pub fn write(data: []const u8) void {
    for (data) |c|
        if (c == '\n')
            newLine()
        else
            putChar(c);
    moveCursor(@intCast(u16, column), @intCast(u16, row));
}

fn write_number(input: usize, radix: usize) void {
    if (input == 0)
        putChar('0')
    else {
        var i: usize = 0;
        var number: usize = input;
        var buf: [10]u8 = undefined;
        while (number > 0) {
            buf[i] = @intCast(u8, number % radix);
            number /= radix;
            i += 1;
        }
        while (i > 0) {
            i -= 1;
            if (buf[i] > 9)
                putChar(buf[i] - 10 + 'A')
            else
                putChar(buf[i] + '0');
        }
    }
    moveCursor(@intCast(u16, column), @intCast(u16, row));
}

pub fn write_bin(input: usize) void {
    write("0b");
    write_number(input, 2);
}

pub fn write_dec(input: usize) void {
    write_number(input, 10);
}

pub fn write_hex(input: usize) void {
    write("0x");
    write_number(input, 16);
}

pub fn vgaEntryColor(fg: VgaColor, bg: VgaColor) u8 {
    return @enumToInt(fg) | (@enumToInt(bg) << 4);
}

pub fn setColor(fg: VgaColor, bg: VgaColor) void {
    color = vgaEntryColor(fg, bg);
}

pub fn disableCursor() void {
    vga_index.write(0x0A);
    vga_data.write(0x20);
}

/// start is row where cursor starts, end is row where cursor ends
pub fn enableCursor(start: u8, end: u8) void {
    vga_index.write(0x0A);
    vga_data.write(vga_data.read() & 0xC0 | start);
    vga_index.write(0x0B);
    vga_data.write(vga_data.read() & 0xE0 | end);
}

/// x is column, y is row
pub fn moveCursor(x: u16, y: u16) void {
    const position = y * VGA_WIDTH + x;
    vga_index.write(0x0F);
    vga_data.write(@intCast(u8, (position & 0xFF)));
    vga_index.write(0x0E);
    vga_data.write(@intCast(u8, (position >> 8) & 0xFF));
}

pub fn delete() void {
    if (column > 8)
        column -= 1;
    putCharAt(' ', color, column, row);
    moveCursor(@intCast(u16, column), @intCast(u16, row));
}

const Position = struct {
    x: u16,
    y: u16,
};

pub fn getCursor() Position {
    var position: u16 = 0;
    vga_index.write(0x0F);
    position |= vga_data.read();
    vga_index.write(0x0E);
    position |= @as(u16, vga_data.read()) << 8;
    return .{
        .x = position % VGA_WIDTH,
        .y = position / VGA_WIDTH,
    };
}

pub fn prompt() void {
    setColor(.Green, .Black);
    write("oddos ");
    setColor(.LightBlue, .Black);
    write("> ");
    setColor(.White, .Black);
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
    if (column == VGA_WIDTH)
        newLine();
}

fn newLine() void {
    column = 0;
    row += 1;
    if (row == VGA_HEIGHT) {
        moveLinesUp();
        column = 0;
        row -= 1;
    }
}

fn moveLinesUp() void {
    var y: usize = 1;
    while (y < VGA_HEIGHT) : (y += 1) {
        var x: usize = 0;
        while (x < VGA_WIDTH) : (x += 1) {
            const letter = buffer[y * VGA_WIDTH + x];
            buffer[(y - 1) * VGA_WIDTH + x] = letter;
        }
    }
    clearRow();
}

fn clearRow() void {
    var x: usize = 0;
    while (x < VGA_WIDTH) : (x += 1)
        putCharAt(' ', color, x, row - 1);
}
