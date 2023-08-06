const std = @import("std");
const hamming = @import("../hamming.zig");
const scoring = @import("../scoring.zig");
const xor = @import("../xor.zig");

// This file was base64'd after being encrypted with repeating-key XOR.
const file = @embedFile("../data/6.txt");
// 1. Let KEYSIZE be the guessed length of the key; try values from 2 to (say) 40.
const KEYSIZE_MIN = 2;
const KEYSIZE_MAX = 40;

test "Challenge 6" {
    // *let's remove newlines from data
    @setEvalBranchQuota(10_000);
    const dataLen = file.len - comptime std.mem.count(u8, file, &.{'\n'});
    var withoutNL: [dataLen]u8 = undefined;
    _ = std.mem.replace(u8, file, &.{'\n'}, &.{}, &withoutNL);

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const decoder = std.base64.standard.Decoder;
    var b64DecodedBuf: [file.len / 4 * 3]u8 = undefined; // actual bytes will be around 3/4 of base64 length
    const b64Len = try decoder.calcSizeForSlice(&withoutNL);
    try decoder.decode(&b64DecodedBuf, &withoutNL);
    const data = b64DecodedBuf[0..b64Len];

    // 2. Write a function to compute the edit distance/Hamming distance between two strings.
    // The distance between:
    const s1 = "this is a test";
    // and
    const s2 = "wokka wokka!!!";
    // is 37.
    try std.testing.expect(try hamming.distance(s1, s2) == 37);

    // 3. For each KEYSIZE, take the first KEYSIZE worth of bytes, and the second KEYSIZE worth of bytes,
    // and find the edit distance between them. Normalize this result by dividing by KEYSIZE.
    var KEYSIZE: usize = KEYSIZE_MIN;
    var probableKey = struct { distance: f32 = std.math.floatMax(f32), keysize: usize = 0 }{};
    while (KEYSIZE <= KEYSIZE_MAX) : (KEYSIZE += 1) {
        // 4. The KEYSIZE with the smallest normalized edit distance is probably the key.
        // You could proceed perhaps with the smallest 2-3 KEYSIZE values. Or take 4 KEYSIZE blocks
        // instead of 2 and average the distances.
        const chunks = [_][]const u8{
            data[0..KEYSIZE],                 data[KEYSIZE .. KEYSIZE * 2],
            data[KEYSIZE * 2 .. KEYSIZE * 3], data[KEYSIZE * 3 .. KEYSIZE * 4],
        };
        const distances = [_]usize{
            try hamming.distance(chunks[0], chunks[1]),
            try hamming.distance(chunks[0], chunks[2]),
            try hamming.distance(chunks[0], chunks[3]),
            try hamming.distance(chunks[1], chunks[2]),
            try hamming.distance(chunks[1], chunks[3]),
            try hamming.distance(chunks[2], chunks[3]),
        };
        var average: f32 = 0;
        for (distances) |distance| average += @as(f32, @floatFromInt(distance)) / @as(f32, @floatFromInt(KEYSIZE));
        average /= @as(f32, @floatFromInt(distances.len));
        if (average < probableKey.distance) probableKey = .{ .distance = average, .keysize = KEYSIZE };
    }
    const guessedSize = probableKey.keysize;

    // 5. Now that you probably know the KEYSIZE: break the ciphertext into blocks of KEYSIZE length.
    // 6. Now transpose the blocks: make a block that is the first byte of every block,
    // and a block that is the second byte of every block, and so on.
    var chunks = try allocator.alloc(std.ArrayList(u8), guessedSize);
    for (chunks) |*chunk| chunk.* = try std.ArrayList(u8).initCapacity(allocator, data.len / guessedSize + 1);
    for (data, 0..) |v, i| {
        try chunks[i % guessedSize].append(v);
    }

    // 7. Solve each block as if it was single-character XOR. You already have code to do this.
    var i: usize = 0;
    var keyBytes = try allocator.alloc(u8, guessedSize);
    while (i < guessedSize) : (i += 1) {
        const read = chunks[i].items;
        const result = try scoring.mostProbableString(read, allocator);
        keyBytes[i] = result.byte;
    }

    const fileName = "out/6_deciphered.txt";
    var fileOut = try std.fs.cwd().createFile(fileName, .{});
    defer fileOut.close();

    var out = try allocator.alloc(u8, data.len);
    const result = try xor.repeatingKeyXor(data, keyBytes, out);
    try fileOut.writeAll(result);
    std.debug.print("KEY IS \"{s}\"; deciphered text written to {s}\n", .{ keyBytes, fileName });
    // std.debug.print("==== DECIPHERED TEXT ====\n{s}\n=========================\n", .{result});
}
