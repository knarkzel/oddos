const std = @import("std");
const Target = @import("std").Target;
const CrossTarget = @import("std").zig.CrossTarget;

pub fn build(b: *std.build.Builder) !void {
    const target = CrossTarget{
        .cpu_arch = Target.Cpu.Arch.i386,
        .os_tag = Target.Os.Tag.freestanding,
    };
    const mode = b.standardReleaseOptions();

    const kernel = b.addExecutable("kernel.elf", "src/main.zig");
    kernel.setTarget(target);
    kernel.setBuildMode(mode);
    kernel.setLinkerScriptPath(.{ .path = "src/linker.ld" });
    kernel.code_model = .kernel;
    kernel.install();

    const kernel_step = b.step("kernel", "Build the kernel");
    kernel_step.dependOn(&kernel.install_step.?.step);

    const run_cmd = b.addSystemCommand(&.{
        "qemu-system-i386",
        "-kernel",
        "zig-out/bin/kernel.elf",
    });
    run_cmd.step.dependOn(kernel_step);

    const run_step = b.step("run", "Run the kernel");
    run_step.dependOn(&run_cmd.step);
}
