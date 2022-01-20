const std = @import("std");
const r = @import("c.zig").raylib;

const math = std.math;
const invtau = 1/math.tau;

pub const World = struct {
    first: ?*Base = null,
    allocator: *const std.mem.Allocator = undefined,

    pub fn add(self: *World, obj: Base) !*Base {
        const o = try self.allocator.create(Base);
        o.* = obj;
        o.world = self;
        if (self.first) |next| {
            o.next = next;
            next.prev = o;
        }
        self.first = o;
        return o;
    }

    pub fn clear(self: *World) void {
        var o = self.first;
        while (o) |obj| {
            o = obj.next;
            self.allocator.destroy(obj);
        }
        self.first = null;
    }
};

pub const Object = union {
    ship: Ship,
    bullet: Bullet,
};

pub const Base = struct {
    //object system
    prev: ?*Base = null,
    next: ?*Base = null,
    world: *World = undefined,
    object: Object,
    //game
    position: r.Vector2,
    facing: f32,
    size: f32,
    linAcc: r.Vector2 = r.Vector2{
        .x = 0,
        .y = 0
    },
    linVel: r.Vector2 = r.Vector2{
        .x = 0,
        .y = 0
    },
    linInvInert: f32 = 1,
    linInvDrag: f32 = 1,
    angAcc: f32 = 0,
    angVel: f32 = 0,
    angInvInert: f32 = 1,
    angInvDrag: f32 = 1,

    pub fn destroy(self: *Base) void {
        if (self.prev) |prev| {
            prev.next = self.next;
        }
        else if (self == self.world.first) {
            self.world.first = self.next;
        }
        if (self.next) |next| {
            next.prev = self.prev;
        }
        self.world.allocator.destroy(self);
    }

    fn update(self: *Base) !void {
        switch (self.object) {
            .ship => |ship| {
                //thrust controller
                if (ship.accelerate) {
                    self.linAcc = vector2AddPolar(
                        self.linAcc,
                        ship.shipThrust,
                        self.facing
                    );
                }
                //turn controller
                const target = r.Vector2Subtract(
                    self.target,
                    self.position
                );
                const diff = r.Vector2Subtract(
                    target,
                    self.prevTarget
                );
                var t = self.aimassist;
                //aimassist
                if (self.aimassist!=0) {

                }
                const aim = vector2AddScaled(target,t,diff);
                //turning
                if (aim.x != 0 and aim.y != 0) {
                    var angAcc = math.atan2(aim.y,aim.x) * invtau - self.facing;
                    if (angAcc>0.5) {
                        angAcc -= 1;
                    }
                    else if (angAcc<-0.5) {
                        angAcc += 1;
                    }
                    self.angAcc += @maximum(
                        -self.shipTurn,
                        @minimum(
                            angAcc,
                            self.shipTurn
                        )
                    );
                }
                self.prevTarget = target;
            },
            .bullet => |bullet| {
                //bullet update
                if (bullet.lifespan<0) {
                    self.destroy();
                    return;
                }
                else {
                    bullet.lifespan -= 1;
                }
            },
        }
        //base update
        //linear movement
        self.linVel = vector2AddScaled(
            self.linVel,
            self.linInvInert,
            self.linAcc
        );
        self.position = r.Vector2Add(
            self.position,
            self.linVel
        );
        self.linVel = r.Vector2Scale(
            self.linVel,
            self.linInvDrag
        );
        self.linAcc = r.Vector2{
            .x = 0,
            .y = 0
        };
        //angular movement
        self.angVel += self.angInvInert * self.angAcc;
        self.facing += self.angVel;
        if (self.facing < 0 or self.facing >= 1) {
            self.facing = @mod(self.facing,1);
        }
        self.angVel *= self.angInvDrag;
        self.angAcc = 0;
        //update 2
        switch (self.object) {
            .ship => |ship| {
                if (ship.cooldown > 0) {
                    ship.cooldown -= 1;
                    ship.shoot = false;
                }
                else if (ship.shoot) {
                    try self.spawnBullet();
                    ship.cooldown = ship.gunCooldown;
                }
            },
            .bullet => { },
        }
    }
};

pub const Ship = struct {
    //controls
    accelerate: bool = undefined,
    shoot: bool = undefined,
    target: r.Vector2 = undefined,
    //stats
    shipThrust: f32,
    shipTurn: f32,
    hp: u8,
    gunCooldown: u8,
    bulletSpeed: f32,
    bulletSize: f32,
    bulletLifespan: u8,
    //misc
    cooldown: u8 = 0,
    aimassist: f32 = 0,
    prevTarget: r.Vector2 = undefined,

    pub fn new(position: r.Vector2, facing: f32) Base {
        const topSpeed: f32 = 20;
        const thrust: f32 = 0.2;
        return Base{
            .position = position,
            .facing = facing,
            .size = 20,
            .object = Object{.ship = Ship{
                .shipThrust = thrust,
                .shipTurn = 0.005,
                .hp = 10,
                .gunCooldown = 60,
                .bulletSpeed = topSpeed,
                .bulletSize = 4,
                .bulletLifespan = 120,
            }},
            .linInvDrag = 1-(thrust/topSpeed),
            .angInvDrag = 0.8,
        };
    }

    fn spawnBullet(self: *Base) !void {
        switch (self.object) {
            .ship => |ship| {
                _ = try self.world.add(Base{
                    .position = vector2AddPolar(
                        self.position,
                        self.size,
                        self.facing
                    ),
                    .facing = self.facing,
                    .size = ship.bulletSize,
                    .object = Object{.bullet = Bullet{
                        .lifespan = ship.bulletLifespan,
                        .shooter = self,
                    }},
                    .linVel = vector2AddPolar(
                        self.linVel,
                        ship.bulletSpeed,
                        self.facing
                    )
                });
            },
            .bullet => unreachable,
        }
    }
};

pub const Bullet = struct {
    shooter: *Base,
    lifespan: u8,
};

fn vector2AddPolar(vector: r.Vector2, length: f32, rotation: f32) r.Vector2 {
    return r.Vector2Add(
        vector,
        r.Vector2Rotate(
            r.Vector2{
                .x = length,
                .y = 0
            },
            rotation * math.tau
        )
    );
}

fn vector2AddScaled(vector1: r.Vector2, scale: f32, vector2: r.Vector2) r.Vector2 {
    return r.Vector2Add(
        vector1,
        r.Vector2Scale(
            vector2,
            scale
        )
    );
}