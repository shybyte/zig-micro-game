const std = @import("std");
const config = @import("../config.zig");

const gl = @cImport({
    @cDefine("GL_GLEXT_PROTOTYPES", {});
    @cInclude("GL/gl.h");
    // @cInclude("GL/glx.h");
    // @cInclude("GL/glu.h");
    // @cInclude("GL/glext.h");
});

pub fn createShaderProgram(vertex_shader_src: []const u8, fragment_shader_src: []const u8) u32 {
    // compile fragment shader
    const fragment_shader = gl.glCreateShader(gl.GL_FRAGMENT_SHADER);
    gl.glShaderSource(fragment_shader, 1, @ptrCast([*c]const [*c]const u8, &fragment_shader_src), null);
    gl.glCompileShader(fragment_shader);

    var is_fragment_compiled: i32 = 0;
    gl.glGetShaderiv(fragment_shader, gl.GL_COMPILE_STATUS, &is_fragment_compiled);
    if (config.DEBUG and is_fragment_compiled == gl.GL_FALSE) {
        std.debug.print("Fragment Shader Compile Problem, {any}!\n", .{is_fragment_compiled});
    }

    // compile vertex shader
    const vertex_shader = gl.glCreateShader(gl.GL_VERTEX_SHADER);
    gl.glShaderSource(vertex_shader, 1, @ptrCast([*c]const [*c]const u8, &vertex_shader_src), null);
    gl.glCompileShader(vertex_shader);

    var is_vertex_compiled: i32 = 0;
    gl.glGetShaderiv(vertex_shader, gl.GL_COMPILE_STATUS, &is_vertex_compiled);
    if (config.DEBUG and is_vertex_compiled == gl.GL_FALSE) {
        std.debug.print("Vertex Shader Compile Problem, {any}!\n", .{is_vertex_compiled});
        var infoLogLength: gl.GLint = 0;
        gl.glGetShaderiv(vertex_shader, gl.GL_INFO_LOG_LENGTH, &infoLogLength);
        std.debug.print("Error length: {}!\n", .{infoLogLength});
        var message: [1000]u8 = [_]u8{' '} ** 1000;
        gl.glGetShaderInfoLog(vertex_shader, infoLogLength, null, @ptrCast([*c]u8, &message));
        std.debug.print("Error: {s}!\n", .{message});
    }

    // link shader
    const p = gl.glCreateProgram();
    gl.glAttachShader(p, vertex_shader);
    gl.glAttachShader(p, fragment_shader);
    gl.glLinkProgram(p);

    var isLinked: i32 = 0;
    gl.glGetProgramiv(p, gl.GL_LINK_STATUS, &isLinked);
    if (config.DEBUG and isLinked == gl.GL_FALSE) {
        std.debug.print("Shader Link Problem, {any}!\n", .{isLinked});
    }

    gl.glDeleteShader(vertex_shader);
    gl.glDeleteShader(fragment_shader);

    return p;
}
