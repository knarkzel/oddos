const Terminal = @import("../driver/Terminal.zig");

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

pub fn isr_handler(registers: Registers) void {
    Terminal.write("H");
    Terminal.write(&.{@truncate(u8, registers.number) + '0'});
}
