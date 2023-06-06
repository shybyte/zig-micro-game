#version 330 core

layout(location = 0) in vec2 aPos;
uniform vec2 uPlayerPos;

void main() {
    gl_Position = vec4(aPos + uPlayerPos, 0.0, 1.0);
}