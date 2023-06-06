#version 330 core

uniform float iTime;

out vec4 FragColor;

void main()
{
    FragColor = vec4(1.0f, abs(sin(iTime)), 0.0f, 1.0f);
} 