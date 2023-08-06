const std = @import("std");
const scoring = @import("../scoring.zig");

// Detect single-character XOR
// One of the 60-character strings in this file has been encrypted by single-character XOR.
const file = @embedFile("../data/4.txt");
const lineSize = std.mem.indexOf(u8, file, &.{'\n'}).? + 1;

const Final = struct {
    buf: [lineSize]u8 = undefined,
    score: f64 = std.math.floatMax(f64),
    string: []const u8 = undefined,
    line: usize = undefined,
    byte: u8 = undefined,

    fn fillFrom(self: *Final, other: anytype, line: usize) void {
        self.score = other.score;
        self.byte = other.byte;
        std.mem.copy(u8, &self.buf, other.string);
        self.string = self.buf[0..other.string.len];
        self.line = line;
    }
};

test "Challenge 4" {
    var stream = std.io.fixedBufferStream(file);
    const reader = stream.reader();

    const allocator = std.testing.allocator;
    var final = Final{};
    var readBuf: [lineSize]u8 = undefined;
    var hexBuf: [lineSize / 2]u8 = undefined;
    var n: usize = 0;
    while (true) : (n += 1) {
        const read = try reader.readUntilDelimiterOrEof(&readBuf, '\n') orelse break;
        const unHexed = try std.fmt.hexToBytes(&hexBuf, read);
        const result = try scoring.mostProbableString(unHexed, allocator);
        defer allocator.free(result.string);
        if (result.score > final.score) continue;
        final.fillFrom(result, n);
    }
    std.debug.print("\rChallenge  4: STRING IS \"{s}\" on line {} XORed with byte 0x{x}\n", .{
        std.fmt.fmtSliceEscapeLower(final.string), final.line, final.byte,
    });
}
