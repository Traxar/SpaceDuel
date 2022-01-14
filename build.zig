const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("SpaceDuel", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);

    // cImport
    exe.linkLibC();
    // raylib.h
    exe.addIncludeDir("lib/raylib");
    // raylib
    exe.addObjectFile(switch (target.getOsTag()) {
        .windows => "lib/raylib/raylib.lib",
        .linux => "lib/raylib/libraylib.a",
        else => @panic("Unsupported OS")
    });
    // system libs for raylib
    switch (exe.target.toTarget().os.tag) {
        .windows => {
            exe.linkSystemLibrary("winmm");
            exe.linkSystemLibrary("gdi32");
            exe.linkSystemLibrary("opengl32");
        },
        .linux => {
            // exe.linkSystemLibrary("GL");
            exe.linkSystemLibrary("rt");
            exe.linkSystemLibrary("dl");
            exe.linkSystemLibrary("m");
            // exe.linkSystemLibrary("X11");
        },
        else => {
            @panic("Unsupported OS");
        },
    }

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
