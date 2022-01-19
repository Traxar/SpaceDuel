const std = @import("std");
const r = @import("imports.zig").raylib;


pub const World = struct {
    first: ?*Base = null,
    allocator: *const std.mem.Allocator = undefined,

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

    
    pub fn create(world: *World, init: Base) !*Base {
        const obj = try world.allocator.create(Base);
        obj.* = init;
        obj.world = world;
        if (world.first) |next| {
            obj.next = next;
            next.prev = obj;
        }
        world.first = obj;
        return obj;
    }
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
};

pub const Ship = struct {
    todo: u8 = 0,
    // pub fn create(world: *World) !*Base {
    //     const obj = try Base.create(world);
    //     //obj.object = Object{.ship = Ship{}};
    //     return obj;
    // }
};

pub const Bullet = struct {
    todo: u8 = 0,
    // pub fn create(world: *World) !*Base {
    //     const obj = try Base.create(world);
    //     //obj.object = Object{.bullet = Bullet{}};
    //     return obj;
    // }
};