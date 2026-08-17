class_name MaterialLibrary
extends RefCounted
## PBR helpers. Poly Haven CC0 textures + project-owned animal maps.


static func pbr(stem: String, uv_scale := 1.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	var base := "res://assets/environment/textures/%s" % stem
	m.albedo_texture = load("%s_diff_1k.jpg" % base)
	m.normal_enabled = true
	m.normal_texture = load("%s_nor_gl_1k.jpg" % base)
	m.roughness_texture = load("%s_rough_1k.jpg" % base)
	m.metallic = 0.0
	m.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	if uv_scale != 1.0:
		m.uv1_scale = Vector3(uv_scale, uv_scale, uv_scale)
	return m


static func animal(tex_name: String, tint: Color, rough := 0.78) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = load("res://assets/animals/textures/%s" % tex_name)
	m.albedo_color = tint
	m.roughness = rough
	m.metallic = 0.0
	m.rim_enabled = true
	m.rim = 0.12
	m.rim_tint = 0.28
	m.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	return m


static func terrain_blend() -> ShaderMaterial:
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;
uniform sampler2D ground : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D path_tex : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D mud : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D ground_n : hint_normal, filter_linear_mipmap_anisotropic;
uniform sampler2D path_n : hint_normal, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_n : hint_normal, filter_linear_mipmap_anisotropic;
uniform sampler2D ground_r : hint_default_white, filter_linear_mipmap;
uniform sampler2D path_r : hint_default_white, filter_linear_mipmap;
uniform sampler2D mud_r : hint_default_white, filter_linear_mipmap;
varying vec3 world_pos;
void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
void fragment() {
	vec2 uv = world_pos.xz * 0.18;
	vec3 g = texture(ground, uv).rgb;
	vec3 p = texture(path_tex, uv * 1.6).rgb;
	vec3 m = texture(mud, uv * 1.2).rgb;
	float path_w = smoothstep(2.35, 0.55, abs(world_pos.z));
	path_w *= smoothstep(-5.0, 1.0, world_pos.x) * smoothstep(50.0, 42.0, world_pos.x);
	float river = smoothstep(0.15, -0.4, world_pos.y);
	river *= smoothstep(16.0, 19.0, world_pos.x) * smoothstep(36.0, 32.0, world_pos.x);
	river *= smoothstep(-16.5, -14.0, world_pos.z) * smoothstep(-2.0, -4.5, world_pos.z);
	float camp = 1.0 - smoothstep(0.0, 6.5, length(world_pos.xz));
	vec3 col = mix(g, p, path_w);
	col = mix(col, m, clamp(river * 0.85 + camp * 0.35, 0.0, 1.0));
	vec3 nrm = mix(texture(ground_n, uv).rgb, texture(path_n, uv * 1.6).rgb, path_w);
	nrm = mix(nrm, texture(mud_n, uv * 1.2).rgb, clamp(river, 0.0, 1.0));
	float rgh = mix(texture(ground_r, uv).r, texture(path_r, uv * 1.6).r, path_w);
	rgh = mix(rgh, texture(mud_r, uv * 1.2).r, clamp(river, 0.0, 1.0));
	ALBEDO = col * 0.92;
	NORMAL_MAP = nrm;
	ROUGHNESS = clamp(rgh * 0.95 + 0.08, 0.35, 1.0);
	METALLIC = 0.0;
	SPECULAR = 0.25;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = sh
	var tdir := "res://assets/environment/textures"
	mat.set_shader_parameter("ground", load("%s/forest_ground_04_diff_1k.jpg" % tdir))
	mat.set_shader_parameter("path_tex", load("%s/grass_path_3_diff_1k.jpg" % tdir))
	mat.set_shader_parameter("mud", load("%s/brown_mud_03_diff_1k.jpg" % tdir))
	mat.set_shader_parameter("ground_n", load("%s/forest_ground_04_nor_gl_1k.jpg" % tdir))
	mat.set_shader_parameter("path_n", load("%s/grass_path_3_nor_gl_1k.jpg" % tdir))
	mat.set_shader_parameter("mud_n", load("%s/brown_mud_03_nor_gl_1k.jpg" % tdir))
	mat.set_shader_parameter("ground_r", load("%s/forest_ground_04_rough_1k.jpg" % tdir))
	mat.set_shader_parameter("path_r", load("%s/grass_path_3_rough_1k.jpg" % tdir))
	mat.set_shader_parameter("mud_r", load("%s/brown_mud_03_rough_1k.jpg" % tdir))
	return mat
