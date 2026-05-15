shader_type canvas_item;

uniform float wave_speed = 2.0;
uniform float wave_height = 0.02;
uniform float wave_frequency = 10.0;

void fragment() {
    vec2 uv = UV;
    uv.y += sin(uv.x * wave_frequency + TIME * wave_speed) * wave_height;
    COLOR = texture(TEXTURE, uv);
}
