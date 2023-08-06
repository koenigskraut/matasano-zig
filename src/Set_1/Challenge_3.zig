const std = @import("std");
const scoring = @import("../scoring.zig");

// Single-byte XOR cipher
// The hex encoded string:
const input = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736";
// ... has been XOR'd against a single character. Find the key, decrypt the message.

// It is known, that we expect a plain english text, so let's score it and pick the string
// with the highest (or lowest in our case) score, details in scoring.zig

test "Challenge 3" {
    var hexBuf: [input.len / 2]u8 = undefined;
    const unHexed = try std.fmt.hexToBytes(&hexBuf, input);

    const allocator = std.testing.allocator;
    const result = try scoring.mostProbableString(unHexed, allocator);
    defer allocator.free(result.string);
    std.debug.print("\rChallenge  3: STRING IS \"{s}\"\n", .{result.string});
}
