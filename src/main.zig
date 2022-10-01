const Serial = @import("common/Serial.zig");
const Terminal = @import("common/Terminal.zig");
const Interrupts = @import("common/Interrupts.zig");

pub fn init() void {
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
