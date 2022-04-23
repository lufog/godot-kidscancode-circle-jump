shader_type canvas_item;

uniform vec4 color : hint_color;
uniform float alpha : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float speed : hint_range(0, 20);
uniform float glow_radius : hint_range(0, 1);
uniform float glow_width : hint_range(0, 1);

void fragment() {
	vec2 center = vec2(0.5);
	float time = TIME * speed;
	float rad = glow_radius - 0.005 * sin(time);
	float thikness = glow_width + 0.05 * cos(time);
	float dist = distance(UV, center);
	
	COLOR.rgb = color.rgb;
	COLOR.a = texture(TEXTURE, UV).a * alpha + smoothstep(thikness / 2.0, 0.0, abs(dist - rad));
}
