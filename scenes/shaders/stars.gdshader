shader_type sky;

float hash(vec3 p) {
    return fract(sin(dot(p, vec3(12.9898, 78.233, 45.164))) * 43758.5453);
}

void sky() {
    vec3 dir = EYEDIR;
    float star = step(0.997, hash(floor(dir * 800.0)));
    COLOR = vec3(star) * vec3(0.9, 0.95, 1.0);
}