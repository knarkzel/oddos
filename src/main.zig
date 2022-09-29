const Serial = @import("drivers/Serial.zig");
const Terminal = @import("drivers/Terminal.zig");

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
