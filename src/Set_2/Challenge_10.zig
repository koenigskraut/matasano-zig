const std = @import("std");
const b64 = std.base64;
const crypto = @import("../crypto.zig");

// Implement CBC mode

// The file here is intelligible (somewhat) when CBC decrypted against "YELLOW SUBMARINE"
// with an IV of all ASCII 0 (\x00\x00\x00 &c)
const file = @embedFile("../data/10.txt");
var key: [16]u8 = "YELLOW SUBMARINE".*;
var iv = [_]u8{0} ** 16;

test "Challenge 10" {
    @setEvalBranchQuota(10_000);
    const dataLen = file.len - comptime std.mem.count(u8, file, &.{'\n'});
    var withoutNL: [dataLen]u8 = undefined;
    _ = std.mem.replace(u8, file, &.{'\n'}, &.{}, &withoutNL);

    const decoder = b64.standard.Decoder;
    var b64DecodedBuf: [withoutNL.len / 4 * 3]u8 = undefined;
    const size = try decoder.calcSizeForSlice(&withoutNL);
    try decoder.decode(&b64DecodedBuf, &withoutNL);
    const data = b64DecodedBuf[0..size];

    var out = try std.testing.allocator.alloc(u8, data.len);
    defer std.testing.allocator.free(out);

    const result = crypto.CBC.decrypt(data, key, iv, out);
    const fileName = "out/10_deciphered.txt";
    const outFile = try std.fs.cwd().createFile(fileName, .{});
    try outFile.writeAll(result);
    outFile.close();

    std.debug.print("Challenge 10: deciphered text written to {s}\n", .{fileName});
}
