const std = @import("std");

pub const Args = struct {
    const Self = @This();
    files: std.ArrayList([]u8),
    allocator: *std.mem.Allocator,
    index: usize = 0,

    pub fn init(args: *std.process.ArgIterator, allocator: *std.mem.Allocator) Args {
        std.debug.assert(args.skip());

        var files = std.ArrayList([]u8).init(allocator);

        while (args.nextPosix()) |arg| {
          const file = std.fs.cwd().openFile(arg, .{ .read = true })
                catch @panic("Could not open file");

          file.seekTo(0) catch |_| @panic("Could not seek position 0 in file");

          const contents = file.readToEndAlloc(allocator, 10000) catch |_| @panic("Could not read file");

          files.append(contents) catch @panic("Could not append to arraylist");

          // This prematurely frees contents when it is owned by ArrayList
          // contents should be freed when the struct is deinited          
          // defer allocator.free(contents);
        }

        return Args {
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
      for (self.files.items) |item| {
        self.allocator.free(item);
      }
      self.files.deinit();
    }
};
