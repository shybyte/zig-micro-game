#version 330 core

const float PI = 3.14159265359;
uniform float iTime;

out vec4 FragColor;

void main() {
    FragColor = vec4(1.0f, abs(sin(iTime * PI)), 0.0f, 1.0f);
}