const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const Modes = enum{
    init,
    menu,
    pause,
    play,
    stats,
    settings
};

const FPS = 60;
const TXT_REL_SIZE = 20;
const SCR_WIDTH: c_int = 800;
const SCR_HEIGHT: c_int = 450;
var screenWidth = SCR_WIDTH;
var screenHeight = SCR_HEIGHT;
var textSize: c_int = 20;

pub fn main() void {
    //init window
    ray.InitWindow(screenWidth, screenHeight, "SpaceDuel");
    defer ray.CloseWindow();
    ray.SetTargetFPS(FPS);
    //make fullscreen on full resolution
    ToggleFullscreen();
    //init audio
    ray.InitAudioDevice();
    defer ray.CloseAudioDevice();
    //load textures
    //TODO
    //load sounds
    //TODO
    //setup

    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.ClearBackground(ray.RAYWHITE);
        ray.DrawText("Hello, World!", 325, 200, textSize, ray.LIGHTGRAY);
    }
}

fn ToggleFullscreen() void {
    if (ray.IsWindowFullscreen()) {
        screenWidth = SCR_WIDTH;
        screenHeight = SCR_HEIGHT;
    }
    else{
        screenWidth = ray.GetMonitorWidth(ray.GetCurrentMonitor());
        screenHeight = ray.GetMonitorHeight(ray.GetCurrentMonitor());
    }
    ray.SetWindowSize(screenWidth,screenHeight);
    ray.BeginDrawing();
    ray.EndDrawing();
    ray.ToggleFullscreen();
    textSize = @divFloor(
        @minimum(screenWidth,screenHeight),
        TXT_REL_SIZE
    );
}

//fn DrawTextCentered(text: const)

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
