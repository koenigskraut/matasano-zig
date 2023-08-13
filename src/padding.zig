const std = @import("std");

fn calcSizeForBlock(in: usize, blockSize: usize) usize {
    const mod = in % blockSize;
    return in - mod + if (mod != 0) blockSize else 0;
}

pub fn pad(in: []const u8, to: usize, out: []u8) ![]const u8 {
    if (in.len > to) return error.WantedSizeTooSmall;
    const paddingSize = to - in.len;
    if (paddingSize > 0xFF) return error.WantedSizeTooBig;
    std.mem.copyForwards(u8, out, in);
    @memset(out[in.len..], @as(u8, @intCast(paddingSize)));
    return out;
}

pub fn padAlloc(in: []const u8, to: usize, allocator: std.mem.Allocator) ![]const u8 {
    if (in.len > to) return error.WantedSizeTooSmall;
    const paddingSize = to - in.len;
    if (paddingSize > 0xFF) return error.WantedSizeTooBig;
    var buf = try allocator.alloc(u8, to);
    std.mem.copyForwards(u8, buf, in);
    @memset(buf[in.len..], @as(u8, @intCast(paddingSize)));
    return buf;
}

pub fn blockPad(in: []const u8, blockSize: usize, out: []u8) ![]const u8 {
    return try pad(in, calcSizeForBlock(in.len, blockSize), out);
}

pub fn blockPadAlloc(in: []const u8, blockSize: usize, allocator: std.mem.Allocator) ![]const u8 {
    return try padAlloc(in, calcSizeForBlock(in.len, blockSize), allocator);
}
