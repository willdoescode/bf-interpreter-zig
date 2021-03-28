const std = @import("std");
const env = std.process.args;
const print = std.debug.print;

const Args = @import("./args.zig").Args;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

const BYTE_READ_LIMIT: usize = 100000;
const BUFSIZE = 65535;
var buf: [BUFSIZE]u8 = undefined;
var ptr: usize = 0;

fn interpretContents(contents: []const u8) void {
    var s = gpa.allocator.dupe(u8, contents) catch unreachable;
    defer gpa.allocator.free(s);

    buf = [_]u8{0} ** BUFSIZE;
    ptr = 0;

    var i: usize = 0;
    var right = s.len;
    while (i < right) : (i += 1) {
        switch (s[i]) {
            '>' => {
                ptr += 1;
                if (ptr >= BUFSIZE) ptr = 0;
            },
            '<' => {
                ptr -= 1;
                if (ptr < 0) ptr = BUFSIZE - 1;
            },
            '.' => print("{c}", .{buf[ptr]}),
            '+' => buf[ptr] +%= 1,
            '-' => buf[ptr] -%= 1,
            '[' => {
                if (buf[ptr] == 0) {
                    var loop: usize = 1;
                    while (loop > 0) {
                        i += 1;
                        const c = s[i];
                        if (c == '[') loop += 1
                        else if (c == ']') loop -= 1;
                    }
                }
            },
            ']' => {
                var loop: usize = 1;
                while (loop > 0) {
                    i -= 1;
                    const c = s[i];
                    if (c == '[') loop -= 1
                    else if (c == ']') loop += 1;
                }
                i -= 1;
            },
            else => {},
        }
    }
}

// > move cell pointer forward
// < move cell pointer backward
// + increment current cell
// - decrement current cell
// , take a character as input and assign to current cell
// . output character value of current cell
// [ start loop
// ] end loop if current cell is zero

pub fn main() !void {
    defer deinit();

    var args = Args.init(&env(), BYTE_READ_LIMIT, &gpa.allocator);
    defer args.deinit();

    while (args.next()) |content| interpretContents(content);
}


fn deinit() void {
    defer std.debug.assert(!gpa.deinit());
}
