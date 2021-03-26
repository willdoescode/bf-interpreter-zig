const std = @import("std");
const env = std.process.args;
const print = std.debug.print;

const Args = @import("./args.zig").Args;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    defer deinit();

    var args = Args.init(&env(), &gpa.allocator);
    defer args.deinit();
    while (args.next()) |content| {

    }
}

fn deinit() void {
    defer std.debug.assert(!gpa.deinit());
}
