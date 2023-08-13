const std = @import("std");

pub const set1 = struct {
    pub const ch1 = @import("Set_1/Challenge_1.zig");
    pub const ch2 = @import("Set_1/Challenge_2.zig");
    pub const ch3 = @import("Set_1/Challenge_3.zig");
    pub const ch4 = @import("Set_1/Challenge_4.zig");
    pub const ch5 = @import("Set_1/Challenge_5.zig");
    pub const ch6 = @import("Set_1/Challenge_6.zig");
    pub const ch7 = @import("Set_1/Challenge_7.zig");
    pub const ch8 = @import("Set_1/Challenge_8.zig");
};

pub const set2 = struct {
    pub const ch9 = @import("Set_2/Challenge_9.zig");
    pub const ch10 = @import("Set_2/Challenge_10.zig");
};

comptime {
    std.testing.refAllDecls(set1);
    std.testing.refAllDecls(set2);
}
