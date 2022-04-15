const std = @import("std");
const r = @import("c.zig").raylib;
const o = @import("objects.zig");

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
    o.Texture.ship.set(r.LoadTexture("res/sprites/ship.png"));
    defer r.UnloadTexture(o.Texture.ship.get());
    o.Texture.flame.set(r.LoadTexture("res/sprites/flame.png"));
    defer r.UnloadTexture(o.Texture.flame.get());
    o.Texture.bullet.set(r.LoadTexture("res/sprites/bullet.png"));
    defer r.UnloadTexture(o.Texture.bullet.get());
    //load sounds
    o.Sound.shot.set(r.LoadSound("res/sounds/shot.wav"));
    defer r.UnloadSound(o.Sound.shot.get());
    o.Sound.hit.set(r.LoadSound("res/sounds/hit.wav"));
    defer r.UnloadSound(o.Sound.hit.get());
    o.Sound.death.set(r.LoadSound("res/sounds/death.wav"));
    defer r.UnloadSound(o.Sound.death.get());
    //setup

    var mode: Mode = .init;
    var diff: usize = 0;
    var scorePlayer: u8 = undefined;
    var scoreEnemy: u8 = undefined;
    var world = o.World{
        .allocator = &allocator
    };
    defer world.clear();
    var player: *o.Base = undefined;
    var enemy: *o.Base = undefined;

    while (!r.WindowShouldClose()) {
        //UPDATE-------------------------------------------------
        switch (mode) {
            .init => {
                mode = .menu;
                //reset
                scorePlayer = 0;
                scoreEnemy = 0;
                world.clear();
                //setup
                player = try world.add(o.Ship.new(
                    r.Vector2{
                        .x = @intToFloat(f32,screenWidth)/4,
                        .y = @intToFloat(f32,screenHeight)/2,
                    },
                    0.5));
                enemy = try world.add(o.Ship.new(
                    r.Vector2{
                        .x = 3*@intToFloat(f32,screenWidth)/4,
                        .y = @intToFloat(f32,screenHeight)/2,
                    },
                    0));
                enemy.object.ship.shipThrust /= 2;
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
                    enemy.object.ship.accelerate = true;
                    enemy.object.ship.aimassist = @intToFloat(f32,diff)/@intToFloat(f32,diffs.len-1);
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
                //player
                player.object.ship.accelerate = r.IsMouseButtonDown(r.MOUSE_BUTTON_RIGHT);
                player.object.ship.shoot = r.IsMouseButtonDown(r.MOUSE_BUTTON_LEFT);
                player.object.ship.target = r.Vector2{
                    .x = @intToFloat(f32,r.GetMouseX()),
                    .y = @intToFloat(f32,r.GetMouseY())
                };
                //enemy
                enemy.object.ship.shoot = true;
                enemy.object.ship.target = player.position;
                //update
                try world.update();
                //update score
                if (player.hp != 0 or enemy.hp != 0){
                    scorePlayer = 10 - enemy.hp;
                    scoreEnemy = 10 - player.hp;
                }
                if (player.hp == 0 or enemy.hp == 0){
                    mode = .stats;
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
        world.render();
        //text
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
                if (player.hp > 0) {
                    if (scoreEnemy > 0) {
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
                else if (enemy.hp > 0) {
                    if (enemy.hp > 2) {
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
                defer allocator.free(diffText);
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
