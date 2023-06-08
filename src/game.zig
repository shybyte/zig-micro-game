const std = @import("std");
const gfx_utils = @import("./utils/gfx.zig");
const Keys = @import("./utils/keys.zig").Keys;
const synth = @import("./synth.zig");
const tunnel = @import("./tunnel.zig");
const triangle = @import("./triangle.zig");

const gl = @cImport({
    @cInclude("GL/gl.h");
});

var player_x: f32 = 0;
var player_y: f32 = 0;
const player_speed = 0.3;

pub fn init() void {
    triangle.init();
    tunnel.init();
    synth.startSong();
}

pub fn render(screen_width: c_int, screen_height: c_int, time: f32) void {
    tunnel.render(screen_width, screen_height, time);
    triangle.render(player_x, player_y, time);
}

pub fn keyPress(key: Keys) void {
    switch (key) {
        .left => {
            player_x -= player_speed;
            synth.playNote(0, 72);
        },
        .right => {
            player_x += player_speed;
            synth.playNote(0, 76);
        },
        .up => {
            player_y += player_speed;
            synth.playNote(0, 77);
        },
        .down => {
            player_y -= player_speed;
            synth.playNote(0, 69);
        },
        else => {},
    }
}

pub fn keyRelease(key: Keys, time: f64) void {
    _ = time;
    _ = key;
}
