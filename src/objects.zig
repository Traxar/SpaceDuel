const std = @import("std");
const r = @cImport({
    @cInclude("raylib.h");
});

pub const World = struct {
    first: ?*Base = null,
    allocator: *const std.mem.Allocator = undefined,

    pub fn clear(self: *World) void {
        var e = self.first;
        while (e) |ent| {
            e = ent.next;
            self.allocator.destroy(ent);
        }
        self.first = null;
    }
};

const Object = union {
    ship: Ship,
    bullet: Bullet,
};

pub const Base = struct {
    prev: ?*Base = null,
    next: ?*Base = null,
    world: *World = undefined,
    object: Object = undefined,
    
    pub fn create(world: *World) !*Base {
        const ent = try world.allocator.create(Base);
        ent.* = Base{};
        ent.world = world;
        if (world.first) |next| {
            ent.next = next;
            next.prev = ent;
        }
        world.first = ent;
        return ent;
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
    todo: u8 
};

pub const Bullet = struct {
    todo: u8
};