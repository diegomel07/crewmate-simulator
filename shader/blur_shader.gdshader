shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 10.0) = 4.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec4 color = vec4(0.0);
    float total_weight = 0.0;

    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            float weight = 1.0 - (abs(float(x)) + abs(float(y))) * 0.2;
            vec2 offset = vec2(float(x), float(y)) * blur_amount * 0.0015;
            
            color += texture(SCREEN_TEXTURE, SCREEN_UV + offset) * weight;
            total_weight += weight;
        }
    }

    COLOR = color / total_weight;
}