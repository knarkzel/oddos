const gdt = @import("system/gdt.zig");
const idt = @import("system/idt.zig");
const isr = @import("system/isr.zig");
const Serial = @import("driver/Serial.zig");
const Terminal = @import("driver/Terminal.zig");

export fn isr_handler(registers: isr.Registers) void {
    Terminal.setColor(.Red, .Black);
    Terminal.write("\nINTERRUPT OCCURRED: ");
    Terminal.write_dec(registers.number);
    Terminal.disableCursor();
}

pub fn init() void {
    gdt.init();
    idt.init();
    Serial.init();
    Terminal.init();
}

pub fn main() void {
    Terminal.setColor(.Green, .Black);
    Terminal.write("oddos ");
    Terminal.setColor(.LightBlue, .Black);
    Terminal.write("> ");
    Terminal.setColor(.White, .Black);
    asm volatile ("int $0x3");
}
