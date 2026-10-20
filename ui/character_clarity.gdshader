shader_type canvas_item;

// Mild source-space sharpening compensates for softened walk drawings.
// Keep source alpha so the transparent sprite never gains a bright outline.
uniform float amount : hint_range(0.0, 1.0) = 0.55;
varying vec4 vertex_tint;

void vertex() {
	vertex_tint = COLOR;
}

void fragment() {
	vec4 center = texture(TEXTURE, UV);
	vec2 step_size = TEXTURE_PIXEL_SIZE * 1.5;
	vec3 blurred = (
		texture(TEXTURE, UV + vec2(step_size.x, 0.0)).rgb +
		texture(TEXTURE, UV - vec2(step_size.x, 0.0)).rgb +
		texture(TEXTURE, UV + vec2(0.0, step_size.y)).rgb +
		texture(TEXTURE, UV - vec2(0.0, step_size.y)).rgb
	) * 0.25;
	vec3 sharpened = clamp(center.rgb + (center.rgb - blurred) * amount, vec3(0.0), vec3(1.0));
	COLOR = vec4(sharpened, center.a) * vertex_tint;
}
