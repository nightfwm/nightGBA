const std = @import("std");
const Io = std.Io;

const rom = @import("rom.zig");
const memory = @import("memory.zig");

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());

    const file = try Io.Dir.cwd().openFile(init.io, args[1], .{});
    defer file.close(init.io);

    var read_buf: [4096]u8 = undefined;
    var file_reader = file.reader(init.io, &read_buf);
    const reader = &file_reader.interface;

    const rom_data = try reader.allocRemaining(init.gpa, .unlimited);
    defer init.gpa.free(rom_data);

    const header = try rom.CartridgeHeader.read(rom_data);
    try header.dump();

    var mm = memory.MemoryMap.init(rom_data);
    const entry = mm.read8(0x08000000);
    std.debug.print("first ROM byte: 0x{X:0>4}\n", .{entry});
}
