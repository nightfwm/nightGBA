pub const MemoryMap = struct {
    bios: [16 * 1024]u8,
    work_ram: [256 * 1024]u8,
    work_iram: [32 * 1024]u8,
    io_reg: [1024]u8,

    // Display memory
    palette_ram: [1024]u8,
    vram: [96 * 1024]u8,
    oam: [1024]u8,

    rom: []const u8,

    pub fn init(rom_data: []const u8) MemoryMap {
        var mm: MemoryMap = undefined;
        @memset(&mm.bios, 0);
        @memset(&mm.work_ram, 0);
        @memset(&mm.work_iram, 0);
        @memset(&mm.io_reg, 0);
        @memset(&mm.palette_ram, 0);
        @memset(&mm.vram, 0);
        @memset(&mm.oam, 0);

        mm.rom = rom_data;
        return mm;
    }

    pub fn read8(self: *const MemoryMap, addr: u32) u8 {
        return switch (addr >> 24) {
            0x00 => self.bios[addr & 0x3FFF],
            0x02 => self.work_ram[addr & 0x3FFFF],
            0x03 => self.work_iram[addr & 0x7FFF],
            0x04 => self.io_reg[addr & 0x3FE],
            0x05 => self.palette_ram[addr & 0x3FF],
            0x06 => self.vram[addr & 0x17FFF],
            0x07 => self.oam[addr & 0x3FFF],

            0x08...0x0D => self.rom[(addr & 0x1FFFFFF) % self.rom.len],
            else => 0,
        };
    }

    pub fn read16(self: *const MemoryMap, addr: u32) u16 {
        return @as(u16, self.read8(addr)) |
            @as(u16, self.read8(addr + 1)) << 8;
    }

    pub fn read32(self: *const MemoryMap, addr: u32) u32 {
        return @as(u32, self.read8(addr)) |
            @as(u32, self.read8(addr + 1)) << 8 |
            @as(u32, self.read8(addr + 2)) << 16 |
            @as(u32, self.read8(addr + 3)) << 24;
    }
};
