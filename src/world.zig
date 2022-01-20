const std = @import("std");
const r = @import("c.zig").raylib;

const math = std.math;
const invtau = 1/math.tau;

pub const Texture = enum {
    ship,
    flame,
    bullet,
    pub fn get(self: Texture) r.Texture2D {
        return textures[@enumToInt(self)];
    }
    pub fn set(self: Texture, texture: r.Texture2D) void {
        textures[@enumToInt(self)] = texture;
    }
};

var textures: [@typeInfo(Texture).Enum.fields.len]r.Texture2D = undefined;

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

    pub fn update(self: *World) !void {
        var o = self.first;
        while (o) |obj| {
            o = obj.next;
            try obj.update();
        }
    }

    pub fn render(self: *World) void {
        var o = self.first;
        while (o) |obj| {
            o = obj.next;
            obj.render();
        }
    }
};

const ObjectTag = enum{
    ship,
    bullet
};

pub const Object = union(ObjectTag) {
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
                const target = vector2AddScaled(
                    ship.target,
                    -1,
                    self.position
                );
                const diff = vector2AddScaled(
                    ship.target,
                    -1,
                    ship.prevTarget
                );
                var t = ship.aimassist;
                //aimassist
                if (ship.aimassist!=0) {

                }
                const aim = vector2AddScaled(target,t,diff);
                //turning
                if (aim.x != 0 and aim.y != 0) {
                    var angAcc = math.atan2(f32,aim.y,aim.x) * invtau - self.facing;
                    if (angAcc>0.5) {
                        angAcc -= 1;
                    }
                    else if (angAcc<-0.5) {
                        angAcc += 1;
                    }
                    self.angAcc += @maximum(
                        -ship.shipTurn,
                        @minimum(
                            angAcc,
                            ship.shipTurn
                        )
                    );
                }
                self.object.ship.prevTarget = target;
            },
            .bullet => {
                //bullet update
                if (self.object.bullet.lifespan == 0) {
                    self.destroy();
                    return;
                }
                else {
                    self.object.bullet.lifespan -= 1;
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
        self.position = vector2AddScaled(
            self.position,
            1,
            self.linVel
        );
        self.linVel = vector2Scale(
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
            .ship => {
                if (self.object.ship.cooldown > 0) {
                    self.object.ship.cooldown -= 1;
                    self.object.ship.shoot = false;
                }
                else if (self.object.ship.shoot) {
                    try self.spawnBullet();
                    self.object.ship.cooldown = self.object.ship.gunCooldown;
                }
            },
            .bullet => { },
        }
    }

    fn render(self: *Base) void {
        switch (self.object) {
            .ship => |ship| {
                const scale = self.size/16;
                const shipPos = vector2AddPolar(self.position,16*scale*math.sqrt2,self.facing-0.125);
                r.DrawTextureEx(
                    Texture.ship.get(),
                    shipPos,
                    self.facing*360+90,
                    scale,
                    r.WHITE
                );
                if (ship.accelerate) {
                    const flamePos = vector2AddPolar(self.position,16*scale*math.sqrt2,self.facing-0.375);
                    r.DrawTextureEx(
                        Texture.flame.get(),
                        flamePos,
                        self.facing*360+90,
                        scale,
                        r.WHITE
                    );
                }
            },
            .bullet => {

            },
        }
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
    prevTarget: r.Vector2 = r.Vector2{
        .x = 0,
        .y = 0
    },

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
};

pub const Bullet = struct {
    shooter: *Base,
    lifespan: u8,
};

fn vector2AddPolar(vector: r.Vector2, length: f32, rotation: f32) r.Vector2 {
    return r.Vector2{
        .x = vector.x + length * math.cos(rotation * math.tau),
        .y = vector.y + length * math.sin(rotation * math.tau),
    };
}

fn vector2AddScaled(vector1: r.Vector2, scale: f32, vector2: r.Vector2) r.Vector2 {
    return r.Vector2{
        .x = vector1.x + scale * vector2.x,
        .y = vector1.y + scale * vector2.y,
    };
}

fn vector2Scale(vector: r.Vector2, scale: f32) r.Vector2 {
    return r.Vector2{
        .x = vector.x * scale,
        .y = vector.y * scale,
    };
}