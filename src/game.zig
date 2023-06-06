const std = @import("std");
const gfx_utils = @import("./utils/gfx.zig");
const Keys = @import("./utils/keys.zig").Keys;
const synth = @import("./synth.zig");

const gl = @cImport({
    @cDefine("GL_GLEXT_PROTOTYPES", {});
    @cInclude("GL/gl.h");
    // @cInclude("GL/glx.h");
    // @cInclude("GL/glu.h");
    // @cInclude("GL/glext.h");
});

const fragment_shader_src = @embedFile("shader/triangle.frag");
const vertex_shader_src = @embedFile("shader/triangle.vert");

var player_x: f32 = 0;
var player_y: f32 = 0;
const player_speed = 0.1;

var VBO: gl.GLuint = undefined;
var VAO: gl.GLuint = undefined;
var p: gl.GLuint = undefined;

const vertices = [_]f32{
    -0.1, -0.1,
    0.1,  -0.1,
    0.0,  0.1,
};

pub fn init(allocator: std.mem.Allocator) void {
    _ = allocator;

    p = gfx_utils.createShaderProgram(vertex_shader_src, fragment_shader_src);

    gl.glGenVertexArrays(1, &VAO);
    gl.glBindVertexArray(VAO);

    gl.glGenBuffers(1, &VBO);
    gl.glBindBuffer(gl.GL_ARRAY_BUFFER, VBO);
    gl.glBufferData(gl.GL_ARRAY_BUFFER, @sizeOf(f32) * vertices.len, &vertices, gl.GL_STATIC_DRAW);
    gl.glVertexAttribPointer(0, 2, gl.GL_FLOAT, gl.GL_FALSE, 2 * @sizeOf(f32), null);
    gl.glEnableVertexAttribArray(0);
}

pub fn render(screen_width: c_int, screen_height: c_int, time: f32) void {
    gl.glClearColor(0.0, 0.0, 0.0, 1.0);
    gl.glClear(gl.GL_COLOR_BUFFER_BIT);

    gl.glUseProgram(p);

    gl.glUniform2f(gl.glGetUniformLocation(p, "uPlayerPos"), player_x, player_y);

    gl.glUniform1f(gl.glGetUniformLocation(p, "iTime"), time);
    gl.glUniform3f(gl.glGetUniformLocation(p, "iResolution"), @intToFloat(f32, screen_width), @intToFloat(f32, screen_height), 0);

    gl.glBindVertexArray(VAO);
    gl.glDrawArrays(gl.GL_TRIANGLES, 0, 3);
}

pub fn keyPress(key: Keys, time: f64) void {
    _ = time;

    // std.debug.print("main-game: keyPress: {any}\n", .{key});
    switch (key) {
        .left => {
            player_x -= player_speed;
            synth.playNote(69);
        },
        .right => {
            player_x += player_speed;
            synth.playNote(72);
        },
        .up => {
            player_y += player_speed;
            synth.playNote(76);
        },
        .down => {
            player_y -= player_speed;
            synth.playNote(68);
        },
        else => {},
    }
}

pub fn keyRelease(key: Keys, time: f64) void {
    _ = time;
    _ = key;
}
