const Serial = @import("drivers/Serial.zig");
const Terminal = @import("drivers/Terminal.zig");
const Interrupts = @import("drivers/Interrupts.zig");

pub fn init() void {
    Serial.init();
    Terminal.init();
    // Interrupts.init();
}

pub fn main() void {
    Terminal.setColor(.Green, .Black);
    Terminal.write("oddos ");
    Terminal.setColor(.LightBlue, .Black);
    Terminal.write("> ");
    Terminal.setColor(.White, .Black);
    // var i: u8 = 1;
    // i -= 1;
    // Terminal.write(&.{10 / i});
}
