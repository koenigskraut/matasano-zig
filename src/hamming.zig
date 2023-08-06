const std = @import("std");

pub fn distance(b1: []const u8, b2: []const u8) !usize {
    if (b1.len != b2.len) return error.BufSizeMismatch;
    var count: usize = 0;
    var i: usize = 0;
    while (i < b1.len) : (i += 1) {
        count += @popCount(b1[i] ^ b2[i]);
    }
    return count;
}
