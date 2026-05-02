const std = @import("std");

// const Multiboot = struct { ram_start: u32, boot_mode: u8, slave_id: u8, unused: [26]u8, joy_start: u32 };

pub const CartridgeHeader = struct {
    rom_start: u32,
    nintendo_logo: [156]u8,

    // actual game data
    title: [12]u8,
    game_code: [4]u8,
    maker_code: [2]u8,

    fixed_value: u8 = 0x96, // required to be 96h
    unit_code: u8,
    device_type: u8,
    reserved: [7]u8, // zero filled space
    version: u8,
    checksum: u8,
    reserved2: [2]u8,

    // comptime {
    //     std.debug.assert(@sizeOf(CartridgeHeader) == 0xC0);
    // }

    pub fn read(reader: *std.Io.Reader) !CartridgeHeader {
        const bytes = try reader.takeArray(@sizeOf(CartridgeHeader));
        var header: CartridgeHeader = undefined;
        @memcpy(std.mem.asBytes(&header), bytes);

        return header;
    }

    fn titleSlice(self: *const CartridgeHeader) []const u8 {
        const t = &self.title;
        const end = std.mem.findScalar(u8, t, 0) orelse t.len;
        return t[0..end];
    }

    fn gameCodeSlice(self: *const CartridgeHeader) []const u8 {
        return &self.game_code;
    }

    fn complementCheck(self: *const CartridgeHeader) u8 {
        const raw_bytes = std.mem.asBytes(self);
        var chk: u8 = 0;

        for (raw_bytes[0xA0..0xBD]) |b| chk -%= b;
        return chk -% 0x19;
    }

    pub fn dump(self: *const CartridgeHeader) !void {
        std.debug.print(
            \\--- GBA Header ---
            \\  Title:            {s}
            \\  Game Code:        {s}
            \\  Maker Code:       {s}
            \\  Version:          0x{X:0>2}
            \\  Complement Check: 0x{X:0>2} (calc: 0x{X:0>2})
            \\  Fixed Value:      0x{X:0>2} ({s})
            \\------------------
            \\
        , .{
            self.titleSlice(),
            self.gameCodeSlice(),
            self.maker_code,
            self.version,
            self.checksum,
            self.complementCheck(),
            self.fixed_value,
            if (self.fixed_value == 0x96) "OK" else "INVALID",
        });
    }
};
