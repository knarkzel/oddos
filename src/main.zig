const Serial = @import("driver/Serial.zig");
const Terminal = @import("driver/Terminal.zig");
const gdt = @import("system/gdt.zig");

pub fn init() void {
    gdt.init();
    Serial.init();
    Terminal.init();
}

pub fn main() void {
    Terminal.setColor(.Green, .Black);
    Terminal.write("oddos ");
    Terminal.setColor(.LightBlue, .Black);
    Terminal.write("> ");
    Terminal.setColor(.White, .Black);
}
