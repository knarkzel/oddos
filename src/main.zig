// System
const gdt = @import("system/gdt.zig");
const idt = @import("system/idt.zig");
const isr = @import("system/isr.zig");

// Drivers
const Timer = @import("driver/Timer.zig");
const Serial = @import("driver/Serial.zig");
const Terminal = @import("driver/Terminal.zig");
const Keyboard = @import("driver/Keyboard.zig");

// Utils
const Port = @import("utils.zig").Port;
const wait = @import("utils.zig").wait;
const enable_interrupts = @import("arch/x86/asm.zig").sti;

export fn isr_handler(registers: isr.Registers) void {
    Terminal.write("INTERRUPT OCCURRED: ");
    Terminal.write_hex(registers.number);
}

export fn irq_handler(registers: isr.Registers) void {
    if (registers.number >= 40)
        Port(u8).init(0xA0).write(0x20); // Send reset signal to slave
    Port(u8).init(0x20).write(0x20); // Send reset signal to master
    if (isr.get_handler(registers.number)) |handler|
        handler(registers);
}

pub fn init() void {
    gdt.init();
    idt.init();
    Serial.init();
    Terminal.init();
    Timer.init(50);
    enable_interrupts();
}

pub fn main() void {
    Terminal.setColor(.Green, .Black);
    Terminal.write("oddos ");
    Terminal.setColor(.LightBlue, .Black);
    Terminal.write("> ");
    Terminal.setColor(.White, .Black);
}
