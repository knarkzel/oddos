const gdt = @import("system/gdt.zig");
const idt = @import("system/idt.zig");
const Serial = @import("driver/Serial.zig");
const Terminal = @import("driver/Terminal.zig");

const Registers = struct {
    ds: u32,
    edi: u32,
    esi: u32,
    ebp: u32,
    esp: u32,
    ebx: u32,
    edx: u32,
    ecx: u32,
    eax: u32,
    number: u32,
    error_code: u32,
    eip: u32,
    cs: u32,
    eflags: u32,
    useresp: u32,
    ss: u32,
};

export fn isr_handler() void {
    Terminal.write("\nINTERRUPT OCCURRED");
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
