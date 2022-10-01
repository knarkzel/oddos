const Serial = @import("common/Serial.zig");
const Terminal = @import("common/Terminal.zig");
const Interrupts = @import("common/Interrupts.zig");

pub fn init() void {
    Serial.init();
    Terminal.init();
    Interrupts.init();
}

pub fn main() void {
    Terminal.setColor(.Green, .Black);
    Terminal.write("oddos ");
    Terminal.setColor(.LightBlue, .Black);
    Terminal.write("> ");
    Terminal.setColor(.White, .Black);

    var i: u8 = 1;
    i -= 1;
    Terminal.write(&.{10 / i});
}
