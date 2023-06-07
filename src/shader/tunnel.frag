#version 330 core

const float PI = 3.14159265359;

uniform float iTime;
uniform vec2 iResolution;

out vec4 fragColor;

void main() {
	vec2 fragCoord = gl_FragCoord.xy;

	vec2 uv = 2. * fragCoord.xy - iResolution.xy;
	uv /= max(iResolution.x, iResolution.y);

	uv += vec2(sin(iTime / 3.423), cos(iTime / 4.52)) * sin(iTime / 200);

	float rad = length(uv) + sin(iTime / 123) * (cos(iTime + uv.y * 1.123) + sin(iTime / 1.3));
	float ang = atan(uv.x, uv.y) + sin(iTime / 100) * sin(iTime + uv.x) + sin(iTime / 2);

	vec2 tex_uv = vec2(ang / PI * 2, 1. / rad + iTime);

	float weird = sin(tex_uv.x * 4 * PI) + sin(tex_uv.y * 4 * PI);
	fragColor = vec4(sin(weird + iTime * 1.1), sin(weird + iTime * 1.2), sin(weird + iTime * 1.3), 0.0) * rad;
}