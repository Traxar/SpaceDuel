const std = @import("std");
const r = @cImport({
    @cInclude("raylib.h");
});

pub var allocator: *const std.mem.Allocator = undefined;

pub const Base = struct {
    prev: ?*Base = null,
    next: ?*Base = null,
    
    pub fn create() !*Base {
        const result = try allocator.create(Base);
        result.* = Base{};
        return result;
    }
    pub fn add(self: *Base, obj: *Base) void {
        obj.next = self.next;
        obj.prev = self;
        if (self.next) |next| {
            next.prev = obj;
        }
        self.next = obj;
    }
};