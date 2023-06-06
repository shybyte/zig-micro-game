const std = @import("std");
const linux = std.os.linux;

pub export fn _start() callconv(.Naked) noreturn {
    _ = linux.write(1, "Hello\n", 6);
    linux.exit(0);
}
