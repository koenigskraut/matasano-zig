const std = @import("std");
const aes = std.crypto.core.aes;
const xor = @import("xor.zig");

pub const ECB = struct {
    pub fn decrypt(in: []const u8, key: anytype, out: []u8) []const u8 {
        if (@typeInfo(@TypeOf(key)) != .Array) @compileError("Invalid key");
        const keySize = key.len;
        const decoder = switch (keySize) {
            16 => aes.Aes128.initDec(key),
            32 => aes.Aes256.initDec(key),
            else => @compileError(std.fmt.comptimePrint("Wrong key size: {}", .{keySize})),
        };
        var i: usize = 0;
        while (i < in.len) : (i += keySize) {
            const start = i;
            const end = i + keySize;
            decoder.decrypt(@as(*[keySize]u8, @ptrCast(out[start..end].ptr)), @as(*const [keySize]u8, @ptrCast(in[start..end].ptr)));
        }
        const lastChar = out[out.len - 1];
        const supposed = std.mem.trimRight(u8, out[0..], &.{lastChar});
        const result: []const u8 = if (supposed.len == out.len -| lastChar) supposed else out[0..];
        return result;
    }

    pub fn encrypt(in: []const u8, key: anytype, out: []u8) []const u8 {
        if (@typeInfo(@TypeOf(key)) != .Array) @compileError("Invalid key");
        const keySize = key.len;
        const encoder = switch (keySize) {
            16 => aes.Aes128.initEnc(key),
            32 => aes.Aes256.initEnc(key),
            else => @compileError(std.fmt.comptimePrint("Wrong key size: {}", .{keySize})),
        };
        var i: usize = 0;
        while (i < in.len) : (i += keySize) {
            const start = i;
            const end = i + keySize;
            encoder.encrypt(@as(*[keySize]u8, @ptrCast(out[start..end].ptr)), @as(*const [keySize]u8, @ptrCast(in[start..end].ptr)));
        }
        const lastChar = out[out.len - 1];
        const supposed = std.mem.trimRight(u8, out[0..], &.{lastChar});
        const result: []const u8 = if (supposed.len == out.len -| lastChar) supposed else out[0..];
        return result;
    }
};

pub const CBC = struct {
    pub fn decrypt(in: []const u8, key: anytype, iv: @TypeOf(key), out: []u8) []const u8 {
        if (@typeInfo(@TypeOf(key)) != .Array) @compileError("Invalid key");
        const keySize = key.len;
        const decoder = switch (keySize) {
            16 => aes.Aes128.initDec(key),
            32 => aes.Aes256.initDec(key),
            else => @compileError(std.fmt.comptimePrint("Wrong key size: {}", .{keySize})),
        };
        var i: usize = 0;
        while (i < in.len) : (i += keySize) {
            const start = i;
            const end = i + keySize;
            var xorWith = if (i == 0) iv else @as(*const [keySize]u8, @ptrCast(in[start - keySize .. start].ptr)).*;
            var dst = @as(*[keySize]u8, @ptrCast(out[start..end].ptr));
            const src = @as(*const [keySize]u8, @ptrCast(in[start..end].ptr));
            decoder.decrypt(dst, src);
            _ = xor.bufSliceXor(out[start..end], &xorWith, out[start..end]) catch unreachable;
        }
        const lastChar = out[out.len - 1];
        const supposed = std.mem.trimRight(u8, out[0..], &.{lastChar});
        const result: []const u8 = if (supposed.len == out.len -| lastChar) supposed else out[0..];
        return result;
    }

    pub fn encrypt(in: []const u8, key: anytype, iv: @TypeOf(key), out: []u8) []const u8 {
        _ = iv;
        if (@typeInfo(@TypeOf(key)) != .Array) @compileError("Invalid key");
        const keySize = key.len;
        const encoder = switch (keySize) {
            16 => aes.Aes128.initEnc(key),
            32 => aes.Aes256.initEnc(key),
            else => @compileError(std.fmt.comptimePrint("Wrong key size: {}", .{keySize})),
        };
        // const iv = @ptrCast(*[keySize]u8, out[0..keySize].ptr);
        var i: usize = keySize;
        while (i < in.len) : (i += keySize) {
            const start = i;
            const end = i + keySize;
            var xorWith = @as(*[keySize]u8, @ptrCast(in[start - keySize .. start].ptr)).*;
            encoder.xor(@as(*[keySize]u8, @ptrCast(out[start..end].ptr)), @as(*const [keySize]u8, @ptrCast(in[start..end].ptr)), xorWith);
        }
        const lastChar = out[out.len - 1];
        const supposed = std.mem.trimRight(u8, out[0..], &.{lastChar});
        const result: []const u8 = if (supposed.len == out.len -| lastChar) supposed else out[0..];
        return result;
    }
};
