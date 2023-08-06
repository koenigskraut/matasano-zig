const std = @import("std");

pub fn bufSliceXor(b1: []const u8, b2: []const u8, out: []u8) ![]const u8 {
    if (b1.len != b2.len or b1.len > out.len) return error.BufSizeMismatch;
    for (out[0..b1.len], 0..) |*v, i| v.* = b1[i] ^ b2[i];
    return out[0..b1.len];
}

pub fn bufScalarXor(buf: []const u8, scalar: u8, out: []u8) ![]const u8 {
    if (buf.len > out.len) return error.BufSizeMismatch;
    for (out[0..buf.len], 0..) |*v, i| v.* = buf[i] ^ scalar;
    return out[0..buf.len];
}
