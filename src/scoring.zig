const std = @import("std");
const xor = @import("xor.zig");

// character frequencies copied from
// https://raw.githubusercontent.com/piersy/ascii-char-frequency-english/main/ascii_freq.txt
const freqs = std.ComptimeStringMap(f64, charFreqs);

// let's assign some scores for individual characters
inline fn realScoreCharacter(char: u8, k: f64) !f64 {
    // immediately disqualify any string containing characters out of range [0;126]
    if (char > 126) return error.OutOfASCII;
    // get char calculated frequency and multiply it by recalculating coefficient,
    // that assumes that total frequency of present chars is 100%
    return (freqs.get(&[1]u8{char}) orelse 0) * k;
}

pub fn realScoreText(string: []const u8) !f64 {
    // precalculated frequencies and counts for existing chars, indeces are chars
    var precalculated: @Vector(128, f64) = @splat(0);
    var charCount = [_]u32{0} ** 128;

    for (string) |char| {
        const p = freqs.get(&[_]u8{char}) orelse return error.NonASCIISymbol;
        if (charCount[char] == 0) {
            charCount[char] = 1;
            precalculated[char] = p;
        } else charCount[char] += 1;
    }
    // coeff for recalculation frequencies assuming that total frequency of present chars is 100%
    const correction = 1 / @reduce(.Add, precalculated);

    // final score (sum of absolute deviations)
    var score: f64 = 0;
    const len = @as(f64, @floatFromInt(string.len));
    for (charCount, 0..) |count, char| {
        if (count == 0) continue;
        const realFrequency = @as(f64, @floatFromInt(count)) / len;
        const calcFrequency = try realScoreCharacter(@as(u8, @intCast(char)), correction);
        score += @fabs(realFrequency - calcFrequency);
    }
    // averaged by number of different chars
    score /= len;

    return score;
}

const Result = struct {
    string: []const u8,
    score: f64,
    byte: u8,
};

pub fn mostProbableString(bytes: []u8, allocator: std.mem.Allocator) !Result {
    var c: u9 = 0;
    var xoredBuf = try allocator.alloc(u8, bytes.len);
    defer allocator.free(xoredBuf);

    var finalScore: f64 = std.math.floatMax(f64);
    var finalString = try allocator.alloc(u8, bytes.len);
    var finalByte: u8 = undefined;

    while (c <= 0xFF) : (c += 1) {
        const xored = try xor.bufScalarXor(bytes, @as(u8, @truncate(c)), xoredBuf);
        const score = realScoreText(xored) catch continue;
        if (score > finalScore) continue;
        finalScore = score;
        std.mem.copy(u8, finalString, xored);
        finalByte = @as(u8, @truncate(c));
    }
    return .{ .string = finalString, .score = finalScore, .byte = finalByte };
}

const charFreqs = .{
    .{ &[1]u8{32}, 0.167564443682168 },
    .{ &[1]u8{101}, 0.08610229517681191 },
    .{ &[1]u8{116}, 0.0632964962389326 },
    .{ &[1]u8{97}, 0.0612553996079051 },
    .{ &[1]u8{110}, 0.05503703643138501 },
    .{ &[1]u8{105}, 0.05480626188138746 },
    .{ &[1]u8{111}, 0.0541904405334676 },
    .{ &[1]u8{115}, 0.0518864979648296 },
    .{ &[1]u8{114}, 0.051525029341199825 },
    .{ &[1]u8{108}, 0.03218192615049607 },
    .{ &[1]u8{100}, 0.03188948073064199 },
    .{ &[1]u8{104}, 0.02619237267611581 },
    .{ &[1]u8{99}, 0.02500268898936656 },
    .{ &[1]u8{10}, 0.019578060965172565 },
    .{ &[1]u8{117}, 0.019247776378510318 },
    .{ &[1]u8{109}, 0.018140172626462205 },
    .{ &[1]u8{112}, 0.017362092874808832 },
    .{ &[1]u8{102}, 0.015750347191785568 },
    .{ &[1]u8{103}, 0.012804659959943725 },
    .{ &[1]u8{46}, 0.011055184780313847 },
    .{ &[1]u8{121}, 0.010893686962847832 },
    .{ &[1]u8{98}, 0.01034644514338097 },
    .{ &[1]u8{119}, 0.009565830104169261 },
    .{ &[1]u8{44}, 0.008634492219614468 },
    .{ &[1]u8{118}, 0.007819143740853554 },
    .{ &[1]u8{48}, 0.005918945715880591 },
    .{ &[1]u8{107}, 0.004945712204424292 },
    .{ &[1]u8{49}, 0.004937789430804492 },
    .{ &[1]u8{83}, 0.0030896915651553373 },
    .{ &[1]u8{84}, 0.0030701064687671904 },
    .{ &[1]u8{67}, 0.002987392712176473 },
    .{ &[1]u8{50}, 0.002756237869045172 },
    .{ &[1]u8{56}, 0.002552781042488694 },
    .{ &[1]u8{53}, 0.0025269211093936652 },
    .{ &[1]u8{65}, 0.0024774830020061096 },
    .{ &[1]u8{57}, 0.002442242504945237 },
    .{ &[1]u8{120}, 0.0023064144740073764 },
    .{ &[1]u8{51}, 0.0021865587546870337 },
    .{ &[1]u8{73}, 0.0020910417959267183 },
    .{ &[1]u8{45}, 0.002076717421222119 },
    .{ &[1]u8{54}, 0.0019199098857390264 },
    .{ &[1]u8{52}, 0.0018385271551164353 },
    .{ &[1]u8{55}, 0.0018243295447897528 },
    .{ &[1]u8{77}, 0.0018134911904778657 },
    .{ &[1]u8{66}, 0.0017387002075069484 },
    .{ &[1]u8{34}, 0.0015754276887500987 },
    .{ &[1]u8{39}, 0.0015078622753204398 },
    .{ &[1]u8{80}, 0.00138908405321239 },
    .{ &[1]u8{69}, 0.0012938206232079082 },
    .{ &[1]u8{78}, 0.0012758834637326799 },
    .{ &[1]u8{70}, 0.001220297284016159 },
    .{ &[1]u8{82}, 0.0011037374385216535 },
    .{ &[1]u8{68}, 0.0010927723198318497 },
    .{ &[1]u8{85}, 0.0010426370083657518 },
    .{ &[1]u8{113}, 0.00100853739070613 },
    .{ &[1]u8{76}, 0.0010044809306127922 },
    .{ &[1]u8{71}, 0.0009310209736100016 },
    .{ &[1]u8{74}, 0.0008814561018445294 },
    .{ &[1]u8{72}, 0.0008752446473266058 },
    .{ &[1]u8{79}, 0.0008210528757671701 },
    .{ &[1]u8{87}, 0.0008048270353938186 },
    .{ &[1]u8{106}, 0.000617596049210692 },
    .{ &[1]u8{122}, 0.0005762708620098124 },
    .{ &[1]u8{47}, 0.000519607185080999 },
    .{ &[1]u8{60}, 0.00044107665296153596 },
    .{ &[1]u8{62}, 0.0004404428310719519 },
    .{ &[1]u8{75}, 0.0003808001912620934 },
    .{ &[1]u8{41}, 0.0003314254660634964 },
    .{ &[1]u8{40}, 0.0003307916441739124 },
    .{ &[1]u8{86}, 0.0002556203680692448 },
    .{ &[1]u8{89}, 0.00025194420110965734 },
    .{ &[1]u8{58}, 0.00012036277683200988 },
    .{ &[1]u8{81}, 0.00010001709417636208 },
    .{ &[1]u8{90}, 8.619977698342993e-05 },
    .{ &[1]u8{88}, 6.572732994986532e-05 },
    .{ &[1]u8{59}, 7.41571610813331e-06 },
    .{ &[1]u8{63}, 4.626899793963519e-06 },
    .{ &[1]u8{127}, 3.1057272589618137e-06 },
    .{ &[1]u8{94}, 2.2183766135441526e-06 },
    .{ &[1]u8{38}, 2.0282300466689395e-06 },
    .{ &[1]u8{43}, 1.5211725350017046e-06 },
    .{ &[1]u8{91}, 6.97204078542448e-07 },
    .{ &[1]u8{93}, 6.338218895840436e-07 },
    .{ &[1]u8{36}, 5.070575116672349e-07 },
    .{ &[1]u8{33}, 5.070575116672349e-07 },
    .{ &[1]u8{42}, 4.436753227088305e-07 },
    .{ &[1]u8{61}, 2.5352875583361743e-07 },
    .{ &[1]u8{126}, 1.9014656687521307e-07 },
    .{ &[1]u8{95}, 1.2676437791680872e-07 },
    .{ &[1]u8{9}, 1.2676437791680872e-07 },
    .{ &[1]u8{123}, 6.338218895840436e-08 },
    .{ &[1]u8{64}, 6.338218895840436e-08 },
    .{ &[1]u8{5}, 6.338218895840436e-08 },
    .{ &[1]u8{27}, 6.338218895840436e-08 },
    .{ &[1]u8{30}, 6.338218895840436e-08 },
};
