shader_type canvas_item;

void fragment() {
	vec2 icon_uv = (UV / TEXTURE_PIXEL_SIZE - vec2(119.0, 234.0)) / vec2(130.0, 131.0);
	float mask = 1.0 - smoothstep(0.485, 0.5, length(icon_uv - vec2(0.5)));
	COLOR.a *= mask;
}
