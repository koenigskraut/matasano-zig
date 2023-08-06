const std = @import("std");
const testing = std.testing;

const xor = @import("../xor.zig");

// Fixed XOR
// Write a function that takes two equal-length buffers and produces their XOR combination.

// string
const s1 = "1c0111001f010100061a024b53535009181c";
// XOR'd against
const s2 = "686974207468652062756c6c277320657965";
// should produce
const expected = "746865206b696420646f6e277420706c6179";

test "Challenge_2" {
    var b1: [s1.len / 2]u8 = undefined;
    const buf1 = try std.fmt.hexToBytes(&b1, s1);
    var b2: [s2.len / 2]u8 = undefined;
    const buf2 = try std.fmt.hexToBytes(&b2, s2);

    var b3: [b1.len]u8 = undefined;
    const resultBuf = try xor.bufSliceXor(buf1, buf2, &b3);

    var b4: [expected.len]u8 = undefined;
    const resultHex = try std.fmt.bufPrint(&b4, "{any}", .{std.fmt.fmtSliceHexLower(resultBuf)});
    try testing.expectEqualSlices(u8, expected, resultHex);
}
