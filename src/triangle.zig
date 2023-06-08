const std = @import("std");
const gfx_utils = @import("./utils/gfx.zig");

const gl = @cImport({
    @cDefine("GL_GLEXT_PROTOTYPES", {});
    @cInclude("GL/gl.h");
});

const vertex_shader_src = @embedFile("shader/triangle.vert");
const fragment_shader_src = @embedFile("shader/triangle.frag");

var VBO: gl.GLuint = undefined;
var VAO: gl.GLuint = undefined;
var p: gl.GLuint = undefined;

const vertices = [_]f32{
    -0.1, -0.1,
    0.1,  -0.1,
    0.0,  0.1,
};

pub fn init() void {
    p = gfx_utils.createShaderProgram(vertex_shader_src, fragment_shader_src);

    gl.glGenVertexArrays(1, &VAO);
    gl.glBindVertexArray(VAO);

    gl.glGenBuffers(1, &VBO);
    gl.glBindBuffer(gl.GL_ARRAY_BUFFER, VBO);
    gl.glBufferData(gl.GL_ARRAY_BUFFER, @sizeOf(f32) * vertices.len, &vertices, gl.GL_STATIC_DRAW);
    gl.glVertexAttribPointer(0, 2, gl.GL_FLOAT, gl.GL_FALSE, 2 * @sizeOf(f32), null);
    gl.glEnableVertexAttribArray(0);
}

pub fn render(player_x: f32, player_y: f32, time: f32) void {
    gl.glUseProgram(p);
    gl.glUniform2f(gl.glGetUniformLocation(p, "uPlayerPos"), player_x, player_y);
    gl.glUniform1f(gl.glGetUniformLocation(p, "iTime"), time);

    gl.glBindVertexArray(VAO);
    gl.glDrawArrays(gl.GL_TRIANGLES, 0, 3);
}
