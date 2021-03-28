const std = @import("std");
const env = std.process.args;
const print = std.io.getStdOut().writer().print;
const stdin_reader = std.io.getStdIn().reader();

const Args = @import("./args.zig").Args;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

const BYTE_READ_LIMIT: usize = 100000;
const BUFSIZE = 65535;
var buf: [BUFSIZE]u8 = undefined;
var ptr: usize = 0;

fn interpretContents(s: []const u8) !void {
    buf = [_]u8{0} ** BUFSIZE;
    ptr = 0;

    var i: usize = 0;
    while (i < s.len) : (i += 1) {
        switch (s[i]) {
            '>' => {
                ptr += 1;
                if (ptr >= BUFSIZE) ptr = 0;
            },
            '<' => {
                ptr -= 1;
                if (ptr < 0) ptr = BUFSIZE - 1;
            },
            '.' => try print("{c}", .{buf[ptr]}),
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
            ',' => buf[ptr] = try stdin_reader.readByte(),
            else => {},
        }
    }
}

pub fn main() !void {
    defer std.debug.assert(!gpa.deinit());

    var args = Args.init(&env(), BYTE_READ_LIMIT, &gpa.allocator);
    defer args.deinit();

    while (args.next()) |content| try interpretContents(content);
}
