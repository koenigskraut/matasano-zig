const std = @import("std");
const fmt = std.fmt;
const testing = std.testing;
const xor = @import("../xor.zig");

// Implement repeating-key XOR
// Here is the opening stanza of an important work of the English language:
const input =
    \\Burning 'em, if you ain't quick and nimble
    \\I go crazy when I hear a cymbal
;
// Encrypt it, under the key "ICE", using repeating-key XOR.
const key = "ICE";
// In repeating-key XOR, you'll sequentially apply each byte of the key;
// the first byte of plaintext will be XOR'd against I, the next C, the next E,
// then I again for the 4th byte, and so on.
// It should come out to:
const expected = "0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f";

test "Challenge 5" {
    var xorBuf: [input.len]u8 = undefined;
    const xored = try xor.repeatingKeyXor(input, key, &xorBuf);
    var hexBuf: [input.len * 2]u8 = undefined;
    const result = try fmt.bufPrint(&hexBuf, "{}", .{fmt.fmtSliceHexLower(xored)});
    try testing.expectEqualSlices(u8, expected, result);
}
