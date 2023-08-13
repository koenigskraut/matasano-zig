const std = @import("std");
const padding = @import("../padding.zig");

// Implement PKCS#7 padding

test "Challenge 9" {
    const input = "YELLOW SUBMARINE";
    const expected = "YELLOW SUBMARINE\x04\x04\x04\x04";
    var buf: [expected.len]u8 = undefined;
    const actual = try padding.pad(input, 20, &buf);
    try std.testing.expectEqualStrings(expected, actual);
}
