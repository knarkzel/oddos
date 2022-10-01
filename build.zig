const std = @import("std");
const Target = @import("std").Target;
const CrossTarget = @import("std").zig.CrossTarget;

pub fn build(b: *std.build.Builder) !void {
    const target = CrossTarget{
        .cpu_arch = Target.Cpu.Arch.i386,
        .os_tag = Target.Os.Tag.freestanding,
    };
    const mode = b.standardReleaseOptions();

    const kernel = b.addExecutable("oddos.elf", "src/init.zig");
    kernel.setTarget(target);
    kernel.setBuildMode(mode);
    kernel.setLinkerScriptPath(.{ .path = "src/arch/x86/linker.ld" });
    kernel.code_model = .kernel;
    kernel.install();

    // Kernel step
    const kernel_step = b.step("kernel", "Build the kernel");
    kernel_step.dependOn(&kernel.install_step.?.step);

    // Run step
    const run_cmd = b.addSystemCommand(&.{
        "qemu-system-i386",
        "-kernel",
        "zig-out/bin/oddos.elf",
        "-display",
        "gtk,zoom-to-fit=on",
        "-serial",
        "stdio",
        "-s",
    });
    run_cmd.step.dependOn(kernel_step);

    const run_step = b.step("run", "Run the kernel");
    run_step.dependOn(&run_cmd.step);

    // Iso step
    const dir_cmd = b.addSystemCommand(&.{ "mkdir", "-p", "zig-out/iso/boot/grub" });
    const elf_cmd = b.addSystemCommand(&.{ "cp", "zig-out/bin/oddos.elf", "zig-out/iso/boot" });
    const cfg_cmd = b.addSystemCommand(&.{ "cp", "src/arch/x86/grub.cfg", "zig-out/iso/boot/grub" });
    const grub_cmd = b.addSystemCommand(&.{ "grub-mkrescue", "-o", "zig-out/bin/oddos.iso", "zig-out/iso" });

    const iso_step = b.step("iso", "Build the iso");
    iso_step.dependOn(&grub_cmd.step);
    grub_cmd.step.dependOn(&cfg_cmd.step);
    cfg_cmd.step.dependOn(&elf_cmd.step);
    elf_cmd.step.dependOn(&dir_cmd.step);
    dir_cmd.step.dependOn(kernel_step);

    // Gdb step
    const gdb_cmd = b.addSystemCommand(&.{
        "gdb",
        "--args",
        "zig-out/bin/oddos.elf",
    });
    const gdb_step = b.step("gdb", "Start gdb on kernel");
    gdb_step.dependOn(&gdb_cmd.step);
}
