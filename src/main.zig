const std = @import("std");
const r = @cImport({
    @cInclude("raylib.h");
});
const objs = @import("objects.zig");

const Mode = enum{
    init,
    menu,
    pause,
    play,
    stats,
    settings
};

const diffs = [_][]const u8{
    "recruit",
    "cadet",
    "sergeant",
    "lieutenant",
    "captain",
    "commander"
};

const FPS = 60;
const TXT_REL_SIZE = 20;
const SCR_WIDTH: i32 = 800;
const SCR_HEIGHT: i32 = 450;
var screenWidth = SCR_WIDTH;
var screenHeight = SCR_HEIGHT;
var textSize: i32 = 20;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        if (leaked) @panic("LEAK DETECTED");
    }
    const allocator = gpa.allocator();

    //init window
    r.InitWindow(screenWidth, screenHeight, "SpaceDuel");
    defer r.CloseWindow();
    r.SetTargetFPS(FPS);
    //make fullscreen on full resolution
    //toggleFullscreen();
    //init audio
    r.InitAudioDevice();
    defer r.CloseAudioDevice();
    //load textures
    //TODO
    //load sounds
    //TODO
    //setup



    var mode: Mode = .init;
    var diff: usize = 0;
    var scorePlayer: u8 = undefined;
    var scoreEnemy: u8 = undefined;
    var world = objs.World{
        .allocator = &allocator
    };
    defer world.clear();

    while (!r.WindowShouldClose()) {
        //UPDATE-------------------------------------------------
        switch (mode) {
            .init => {
                mode = .menu;
                scorePlayer = 0;
                scoreEnemy = 0;
                _ = try objs.Base.create(&world);
                _ = try objs.Base.create(&world);
            },
            .menu => {
                if (r.IsKeyPressed(r.KEY_F11)) {
                    toggleFullscreen();
                }
                else if (r.IsKeyPressed(r.KEY_SPACE)) {
                    diff = @mod(diff+1,diffs.len);
                }
                else if (r.IsMouseButtonPressed(r.MOUSE_BUTTON_LEFT) 
                    or r.IsMouseButtonPressed(r.MOUSE_BUTTON_RIGHT)) {
                    mode = .play;
                }
            },
            .pause => {
                if (r.IsKeyPressed(r.KEY_F11)) {
                    toggleFullscreen();
                }
                else if (r.IsMouseButtonPressed(r.MOUSE_BUTTON_LEFT) 
                    or r.IsMouseButtonPressed(r.MOUSE_BUTTON_RIGHT)) {
                    mode = .play;
                }
            },
            .play => {
                if (r.IsKeyPressed(r.KEY_SPACE)) {
                    mode = .pause;
                }
            },
            .stats => {
                if (r.IsKeyPressed(r.KEY_SPACE)) {
                    mode = .init;
                }
            },
            .settings => {
                
            },
        }
        //DRAW---------------------------------------------------
        r.BeginDrawing();
        defer r.EndDrawing();
        r.ClearBackground(r.RAYWHITE);
        //score
        const scoreText = std.fmt.allocPrintZ(allocator,"{d}-{d}",.{scorePlayer,scoreEnemy}) catch "ERROR";
        defer allocator.free(scoreText);
        r.DrawText(scoreText.ptr, textSize, textSize, textSize, r.GRAY);
        //render
        const x = @divFloor(screenWidth,2);
        const y = @divFloor(screenHeight,2);
        switch (mode) {
            .init => {
                drawTextCentered("[LOADING...]",x,y,textSize,r.GRAY);
            },
            .menu => {
                drawTextCentered("SPACE-DUEL",x,y-5*textSize ,4*textSize,r.GRAY);
                const diffText = std.fmt.allocPrintZ(allocator,"[{s}]",.{diffs[diff]}) catch "ERROR";
                defer allocator.free(diffText);
                drawTextCentered(diffText.ptr,x,y-2*textSize,textSize,r.GRAY);
                drawTextCentered("[RMB - move]",x,y,textSize,r.GRAY);
                drawTextCentered("[LMB - shoot]",x,y+2*textSize,textSize,r.GRAY);
                drawTextCentered("[SPACE - change difficulty/pause]",x,y+4*textSize,textSize,r.GRAY);
                drawTextCentered("[ESC - quit]",x,y+6*textSize,textSize,r.GRAY);               
            },
            .pause => {
                drawTextCentered("[PAUSED - click anywhere to continue]",x,y,textSize,r.GRAY);
            },
            .play => {
                
            },
            .stats => {
                var text: [*]const u8 = undefined;
                var subtext: [*]const u8 = undefined;
                if (true) {
                // if (player.hp > 0) {
                    if (true) {
                    // if (scoreEnemy > 0) {
                        text = "GG WP, pilot";
                        subtext = switch (diff) {
                            0,1 => "wanna try a harder difficulty?",
                            2,3 => "you are a promising fighter",
                            4,5 => "what a fight!",
                            else => unreachable
                        };
                    }
                    else {
                        text = "FLAWLESS!";
                        subtext = switch (diff) {
                            0,1 => "scared of a harder difficulty?",
                            2,3 => "already proving your talent",
                            4,5 => "you are a true master!",
                            else => unreachable
                        };
                    }
                }
                else if (true) {
                // else if (enemy.hp > 0) {
                    if (true) {
                    // if (enemy.hp > 2) {
                        text = "GG EZ";
                        subtext = "better luck next time";
                    }
                    else {
                        text = "GG, close";
                        subtext = "but you still lost";
                    }
                }
                else {
                    text = "...";
                    subtext = "what do you think you are doing?";
                }
                drawTextCentered(text,x,y,2*textSize,r.GRAY);
                drawTextCentered(subtext,x,y+2*textSize,textSize,r.GRAY);
                const diffText = std.fmt.allocPrintZ(allocator,"[{s}]",.{diffs[diff]}) catch "ERROR";
                drawTextCentered(diffText.ptr,x,y+4*textSize,textSize,r.GRAY);
                drawTextCentered("[SPACE - continue]",x,y+6*textSize,textSize,r.GRAY);
            },
            .settings => {
                
            },
        }
    }
}

fn toggleFullscreen() void {
    if (r.IsWindowFullscreen()) {
        screenWidth = SCR_WIDTH;
        screenHeight = SCR_HEIGHT;
        r.ToggleFullscreen();
        r.SetWindowSize(screenWidth,screenHeight);
    }
    else{
        screenWidth = r.GetMonitorWidth(r.GetCurrentMonitor());
        screenHeight = r.GetMonitorHeight(r.GetCurrentMonitor());
        r.SetWindowSize(screenWidth,screenHeight);
        r.BeginDrawing();
        r.EndDrawing();
        r.ToggleFullscreen();
    }
    textSize = @divFloor(
        @minimum(screenWidth,screenHeight),
        TXT_REL_SIZE
    );
}

fn drawTextCentered (
    text: [*]const u8,
    x: i32,
    y: i32,
    size: i32,
    color: r.Color) void {
    const dx = @divFloor(r.MeasureText(text,size),2);
    const dy = @divFloor(size,2);
    r.DrawText(text,x - dx,y - dy, size, color);
}

test "basic test" {
    try std.testing.expect(10 == 3 + 7);
}
