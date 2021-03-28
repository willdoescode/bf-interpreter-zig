const std = @import("std");

fn fileError(comptime msg: []const u8, args: anytype) noreturn {
  std.debug.print(msg, args);
  std.process.exit(1);
} 

pub const Args = struct {
    const Self = @This();

    files: std.ArrayList([]u8),
    allocator: *std.mem.Allocator,
    index: usize = 0,

    pub fn init(
        args: *std.process.ArgIterator,
        byte_read_limit: usize,
        allocator: *std.mem.Allocator
      ) Self {
        std.debug.assert(args.skip());

        var files = std.ArrayList([]u8).init(allocator);

        while (args.nextPosix()) |arg| {
          const file = std.fs.cwd().openFile(arg, .{ .read = true })
            catch fileError("Could not open file: {s}\n", .{arg});

          file.seekTo(0)
            catch fileError("Could not seek position 0 in {s}\n", .{file});

          const contents = file.readToEndAlloc(allocator, byte_read_limit)
            catch fileError("Could not read file: {s}\n", .{file});

          files.append(contents) catch unreachable;

          // This prematurely frees contents when it is owned by ArrayList
          // contents should be freed when the struct is deinited          
          // defer allocator.free(contents);
        }

        return Self {
            .files = files,
            .allocator = allocator,
        };
    }

    pub fn next(self: *Self) ?[]const u8 {
      if (self.index < self.files.items.len) {
        defer self.index += 1; 
        return self.files.items[self.index];
      } 
      return null;
    }

    pub fn deinit(self: *Self) void {
      for (self.files.items) |item| self.allocator.free(item);

      self.files.deinit();
    }
};
