// res://scenes/minigames/clear_asteroids/green_vision.gdshader
// Filtro de "visión" verde con grano + viñeta, tipo tarea de destruir asteroides.
// Se aplica a un ColorRect que cubre toda el área del minijuego (nodo "Background").
shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(0.15, 0.65, 0.25, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.55;
uniform float grain_strength : hint_range(0.0, 1.0) = 0.12;
uniform float grain_scale : hint_range(1.0, 20.0) = 3.0;
uniform float grain_speed : hint_range(0.0, 5.0) = .5; // 1.0 = velocidad original, bajalo para que vaya más lento
uniform float vignette_strength : hint_range(0.0, 2.0) = 0.55;
uniform float darken : hint_range(0.0, 1.0) = 0.25; // qué tan oscuro se ve todo debajo
uniform float effect_opacity : hint_range(0.0, 1.0) = .7; // 1.0 = filtro completo, más bajo = más transparente (se ve más la escena real)

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec4 scene = texture(screen_texture, SCREEN_UV);

	// Pasamos la escena a "luma" y la teñimos de verde, como si fuera
	// una cámara de seguridad / visor nocturno.
	float luma = dot(scene.rgb, vec3(0.299, 0.587, 0.114));
	vec3 tinted = mix(scene.rgb, vec3(luma) * tint_color.rgb, tint_strength);
	tinted *= (1.0 - darken);

	// Grano animado (cambia cada frame usando TIME)
	vec2 grain_uv = SCREEN_UV * (300.0 / grain_scale) + vec2(TIME * 37.0, TIME * 59.0) * grain_speed;
	float noise = rand(floor(grain_uv));
	tinted += (noise - 0.5) * grain_strength;

	// Viñeta: oscurece las esquinas para dar sensación de "visor"
	vec2 centered = SCREEN_UV - 0.5;
	float vig = 1.0 - dot(centered, centered) * vignette_strength;
	tinted *= clamp(vig, 0.0, 1.0);

	// Mezcla final: a menor effect_opacity, más se ve la escena original sin filtro
	vec3 final_color = mix(scene.rgb, clamp(tinted, 0.0, 1.0), effect_opacity);

	COLOR = vec4(final_color, scene.a);
}