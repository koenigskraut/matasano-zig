const std = @import("std");

pub const set1 = struct {
    pub const ch1 = @import("Set_1/Challenge_1.zig");
    pub const ch2 = @import("Set_1/Challenge_2.zig");
    pub const ch3 = @import("Set_1/Challenge_3.zig");
    pub const ch4 = @import("Set_1/Challenge_4.zig");
};

comptime {
    std.testing.refAllDecls(set1);
}
