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
	m.rim = 0.18
	m.rim_tint = 0.35
	m.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	return m
