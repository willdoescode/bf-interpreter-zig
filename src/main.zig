const std = @import("std");
const env = std.process.args;
const print = std.debug.print;

const Args = @import("./args.zig").Args;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var cells = std.AutoHashMap(i64, i64).init(&gpa.allocator);
var index: i64 = 0;

const Instruction = union(enum) {
    Back,
    Forward,
    Inc,
    Dec,
    Out,
    Loop: std.ArrayList(Instruction),
    Other
};

pub fn main() !void {
    defer deinit();

    var args = Args.init(&env(), &gpa.allocator);
    defer args.deinit();

    while (args.next()) |arg| {
        var instructions = std.ArrayList(Instruction).init(&gpa.allocator);
        var loop_instructions = std.ArrayList(Instruction).init(&gpa.allocator);
        var loop_on = false;

        for (arg) |content| {
            switch (content) {
                '<' => if (loop_on) try loop_instructions.append(.Back) else try instructions.append(.Back),
                '>' => if (loop_on) try loop_instructions.append(.Forward) else try instructions.append(.Forward),
                '+' => if (loop_on) try loop_instructions.append(.Inc) else try instructions.append(.Inc),
                '-' => if (loop_on) try loop_instructions.append(.Dec) else try instructions.append(.Dec),
                '.' => if (loop_on) try loop_instructions.append(.Out) else try instructions.append(.Out),
                '[' => loop_on = true,
                ']' => blk: {
                    try instructions.append(Instruction{.Loop = loop_instructions}); 
                    loop_instructions.shrinkAndFree(0);
                    loop_on = false;
                    break :blk {};
                },
                else => if (loop_on) try loop_instructions.append(.Other) else try instructions.append(.Other),
            }
            // print("{c}\n", .{text});
        }
        print("{}", .{instructions});

        loop_instructions.deinit();
        instructions.deinit();
    }
}

fn deinit() void {
    defer cells.deinit();
    defer std.debug.assert(!gpa.deinit());
}
