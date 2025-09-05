const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const fmt = std.fmt;
const process = std.process;
const zware = @import("zware");
const Module = zware.Module;
const Store = zware.Store;
const Instance = zware.Instance;
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;
var gpa = GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    defer _ = gpa.deinit();
    var alloc = gpa.allocator();

    var args = try process.argsWithAllocator(alloc);
    defer args.deinit();
    _ = args.skip();
    const filename = args.next() orelse return error.NoFilename;

    const program = try fs.cwd().readFileAlloc(alloc, filename, 0xFFFFFFF);
    defer alloc.free(program);

    var module = Module.init(program);
    defer module.deinit(alloc);
    try module.decode(alloc);

    std.log.info("Imports:", .{});
    for (module.imports.list.items, 0..) |import, i| {
        std.log.info("{}: import = {s}, tag = {}", .{ i, import.name, import.desc_tag });
    }

    std.log.info("Exports:", .{});
    for (module.exports.list.items, 0..) |exprt, i| {
        std.log.info("{}: export = {s}, tag = {}", .{ i, exprt.name, exprt.tag });
    }
}
