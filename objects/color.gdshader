shader_type canvas_item;

uniform vec3 color : hint_color;
uniform float alpha : hint_range(0.0, 1.0, 0.01) = 1.0;

void fragment() {
	COLOR.rgb = color.rgb;
	COLOR.a = texture(TEXTURE, UV).a * alpha;
}
