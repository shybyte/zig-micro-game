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

const vertex_shader_src = @embedFile("shader/triangle.vert");
const fragment_shader_src = @embedFile("shader/triangle.frag");

const tunnel_vertex_shader_src = @embedFile("shader/tunnel.vert");
const tunnel_fragment_shader_src = @embedFile("shader/tunnel.frag");

var player_x: f32 = 0;
var player_y: f32 = 0;
const player_speed = 0.3;

var VBO: gl.GLuint = undefined;
var VAO: gl.GLuint = undefined;
var VAO_QUAD: gl.GLuint = undefined;
var VBO_QUAD: gl.GLuint = undefined;
var p: gl.GLuint = undefined;

var tunnel_shader_program: gl.GLuint = undefined;

const vertices = [_]f32{
    -0.1, -0.1,
    0.1,  -0.1,
    0.0,  0.1,
};

const vertices_quad = [_]f32{ -1, -1, -1, 1, 1, -1, 1, 1 };

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

    tunnel_shader_program = gfx_utils.createShaderProgram(tunnel_vertex_shader_src, tunnel_fragment_shader_src);

    gl.glGenVertexArrays(1, &VAO_QUAD);
    gl.glBindVertexArray(VAO_QUAD);

    gl.glGenBuffers(1, &VBO_QUAD);
    gl.glBindBuffer(gl.GL_ARRAY_BUFFER, VBO_QUAD);
    gl.glBufferData(gl.GL_ARRAY_BUFFER, @sizeOf(f32) * vertices_quad.len, &vertices_quad, gl.GL_STATIC_DRAW);
    gl.glVertexAttribPointer(0, 2, gl.GL_FLOAT, gl.GL_FALSE, 2 * @sizeOf(f32), null);
    gl.glEnableVertexAttribArray(0);

    synth.startSong();
}

pub fn render(screen_width: c_int, screen_height: c_int, time: f32) void {
    gl.glClearColor(0.0, 0.0, 0.0, 1.0);
    gl.glClear(gl.GL_COLOR_BUFFER_BIT);

    gl.glUseProgram(tunnel_shader_program);
    gl.glUniform1f(gl.glGetUniformLocation(tunnel_shader_program, "iTime"), time);
    gl.glUniform2f(gl.glGetUniformLocation(tunnel_shader_program, "iResolution"), @intToFloat(f32, screen_width), @intToFloat(f32, screen_height));

    gl.glBindVertexArray(VAO_QUAD);
    gl.glDrawArrays(gl.GL_TRIANGLE_STRIP, 0, 4);

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
