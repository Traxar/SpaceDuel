const std = @import("std");
const GitRepoStep = @import("GitRepoStep.zig");
const RaylibBuild = @import("dep/raylib/src/build.zig");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const raylib_repo = GitRepoStep.create(b, .{
    .url = "https://github.com/raysan5/raylib",
    .branch = null,
    .sha = "559ffc633164c30824065a63324ba08efa651ee6",
    .fetch_enabled = true,
    });

    const raylib = RaylibBuild.addRaylib(b,target);
    raylib.install();

    const exe = b.addExecutable("SpaceDuel", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);

    exe.step.dependOn(&raylib_repo.step);

    // cImport
    exe.linkLibC();
    // raylib.h
    exe.addIncludeDir("dep/raylib/src");

    exe.addObjectFile(switch (target.getOsTag()) {
        .windows => "zig-out/lib/raylib.lib",
        .linux => "zig-out/lib/libraylib.a",
        else => @panic("Unsupported OS")
    });

    exe.install();

    //todo: copy resources (res) into output dir, so game becomes easily portable

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
