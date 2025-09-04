shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float meltiness : hint_range(0.0, 16.0) = 1.0;
uniform float pixel_size : hint_range(0.001, 0.2) = 0.02;

float psuedo_rand(float x) {
    return mod(x * 2048103.0 + cos(x * 1912.0), 1.0);
}

void fragment() {
    vec2 uv = UV;

    float col = floor(UV.x / pixel_size) * pixel_size;
    uv.y -= progress * meltiness * psuedo_rand(col);

	uv.y -= progress * meltiness * 1.5;
    vec4 tex = texture(TEXTURE, uv);

	if (uv.y < 0.0) {
	    tex.a = 0.0;
	}
	COLOR = tex;
}