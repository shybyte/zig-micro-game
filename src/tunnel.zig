const std = @import("std");
const gfx_utils = @import("./utils/gfx.zig");

const gl = @cImport({
    @cDefine("GL_GLEXT_PROTOTYPES", {});
    @cInclude("GL/gl.h");
});

const tunnel_vertex_shader_src = @embedFile("shader/tunnel.vert");
const tunnel_fragment_shader_src = @embedFile("shader/tunnel.frag");

const vertices_quad = [_]f32{
    -1, -1,
    -1, 1,
    1,  -1,
    1,  1,
};

var VAO_QUAD: gl.GLuint = undefined;
var VBO_QUAD: gl.GLuint = undefined;
var shader_program: gl.GLuint = undefined;

pub fn init() void {
    shader_program = gfx_utils.createShaderProgram(tunnel_vertex_shader_src, tunnel_fragment_shader_src);

    gl.glGenVertexArrays(1, &VAO_QUAD);
    gl.glBindVertexArray(VAO_QUAD);

    gl.glGenBuffers(1, &VBO_QUAD);
    gl.glBindBuffer(gl.GL_ARRAY_BUFFER, VBO_QUAD);
    gl.glBufferData(gl.GL_ARRAY_BUFFER, @sizeOf(f32) * vertices_quad.len, &vertices_quad, gl.GL_STATIC_DRAW);
    gl.glVertexAttribPointer(0, 2, gl.GL_FLOAT, gl.GL_FALSE, 2 * @sizeOf(f32), null);
    gl.glEnableVertexAttribArray(0);
}

pub fn render(screen_width: c_int, screen_height: c_int, time: f32) void {
    gl.glUseProgram(shader_program);
    gl.glUniform1f(gl.glGetUniformLocation(shader_program, "iTime"), time);
    gl.glUniform2f(gl.glGetUniformLocation(shader_program, "iResolution"), @as(f32, @floatFromInt(screen_width)), @as(f32, @floatFromInt(screen_height)));

    gl.glBindVertexArray(VAO_QUAD);
    gl.glDrawArrays(gl.GL_TRIANGLE_STRIP, 0, 4);
}
