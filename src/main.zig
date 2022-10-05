const gdt = @import("system/gdt.zig");
const idt = @import("system/idt.zig");
const Serial = @import("driver/Serial.zig");
const Terminal = @import("driver/Terminal.zig");
export const isr_handler = @import("system/isr.zig").isr_handler;

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
    asm volatile ("int $0x4");
}
