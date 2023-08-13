const std = @import("std");

// Detect AES in ECB mode
// In this file are a bunch of hex-encoded ciphertexts.
const file = @embedFile("../data/8.txt");
// One of them has been encrypted with ECB. Detect it.

test "Challenge 8" {
    var it = std.mem.tokenize(u8, file, &.{'\n'});
    var lineNumber: usize = 1;
    outer: while (it.next()) |line| : (lineNumber += 1) {
        var i: usize = 0;
        while (i < line.len) : (i += 16) {
            const chunk = line[i..][0..16];
            if (std.mem.count(u8, line, chunk) > 1) break :outer;
        }
    }
    std.debug.print("AES-ECB cipher detected on line #{}\n", .{lineNumber});
}
