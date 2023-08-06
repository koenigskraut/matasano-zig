const std = @import("std");
const testing = std.testing;
const b64 = std.base64;

// Convert hex to base64
// The string:
const input = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d";
// Should produce:
const expected = "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t";

test "Challenge_1" {
    var bytesBuf: [input.len / 2]u8 = undefined;
    const bytes = try std.fmt.hexToBytes(&bytesBuf, input);

    var b64Buf: [input.len]u8 = undefined;
    const output = std.base64.standard_no_pad.Encoder.encode(&b64Buf, bytes);

    try testing.expectEqualSlices(u8, expected, output);
}
