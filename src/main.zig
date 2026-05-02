const std = @import("std");
const Io = std.Io;

const rom = @import("rom.zig");

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());

    const file = try Io.Dir.cwd().openFile(init.io, args[1], .{});
    defer file.close(init.io);

    var read_buf: [4096]u8 = undefined;
    var file_reader = file.reader(init.io, &read_buf);

    const reader = &file_reader.interface;

    const header = try rom.CartridgeHeader.read(reader);
    try header.dump();

    std.debug.print("All your {s} are belong to us.\n", .{"labubus"});
}
