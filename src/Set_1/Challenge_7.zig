const std = @import("std");
const b64 = std.base64;
const crypto = @import("../crypto.zig");

// AES in ECB mode
// The Base64-encoded content in this file
const file = @embedFile("../data/7.txt");
// has been encrypted via AES-128 in ECB mode under the key
var fileKey = "YELLOW SUBMARINE".*;

test "Challenge 7" {
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

    const result = crypto.ECB.decrypt(data, fileKey, out);

    const fileName = "out/7_deciphered.txt";
    const outFile = try std.fs.cwd().createFile(fileName, .{});
    try outFile.writeAll(result);
    outFile.close();

    std.debug.print("deciphered text written to {s}\n", .{fileName});
}
