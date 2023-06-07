#version 330 core

const float PI = 3.14159265359;

uniform float iTime;
uniform vec2 uPlayerPos;

layout(location = 0) in vec2 aPos;

void main() {
    gl_Position = vec4(aPos * sin(iTime * 2 * PI) * 3 + uPlayerPos, 0.0, 1.0);
}