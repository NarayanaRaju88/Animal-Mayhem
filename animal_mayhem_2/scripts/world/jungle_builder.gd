class_name JungleBuilder
extends Node3D
## Builds a compact jungle slice: camp, forest, river, rocks, blocked path.

var _canopy_mesh: CapsuleMesh
var _bush_mesh: CapsuleMesh
var _branch_mesh: CylinderMesh
var _flare_mesh: CylinderMesh
var _vine_mesh: CylinderMesh
var _rock_box: BoxMesh
var _bark_pool: Array[StandardMaterial3D] = []
var _leaf_pool: Array[StandardMaterial3D] = []
var _rock_pool: Array[StandardMaterial3D] = []
var _litter_mat: StandardMaterial3D
var _tree_xz: PackedVector2Array = PackedVector2Array()


func build() -> Dictionary:
	_init_jungle_shared()
	_environment()
	_sun()
	_terrain()
	_water()
	_vegetation()
	_landmark()
	_atmosphere()
	_horizon()
	_camp()
	var props := {}
	props["tree"] = _fallen_tree()
	props["ledge"] = _climb()
	props["gap"] = _gap_wall()
	props["post"] = _coil()
	props["gate"] = _vine_gate()
	props["post"].vine_gate = props["gate"]
	props["explorer"] = _explorer()
	return props


func height_at(x: float, z: float) -> float:
	var h := 0.35 * sin(x * 0.09) + 0.28 * cos(z * 0.08) + 0.18 * sin((x + z) * 0.05)
	if x > 18.0 and x < 34.0 and z > -14.0 and z < -4.0:
		h -= 1.8
	if abs(x) < 8.0 and abs(z) < 8.0:
		h = maxf(h, 0.15)
	if x > 22.0 and x < 30.0 and z > 6.0 and z < 16.0:
		h += 0.4
	return h


func _init_jungle_shared() -> void:
	if _canopy_mesh != null:
		return
	_canopy_mesh = CapsuleMesh.new()
	_canopy_mesh.radius = 0.72
	_canopy_mesh.height = 1.85
	_canopy_mesh.radial_segments = 7
	_canopy_mesh.rings = 4
	_bush_mesh = CapsuleMesh.new()
	_bush_mesh.radius = 0.42
	_bush_mesh.height = 0.95
	_bush_mesh.radial_segments = 6
	_bush_mesh.rings = 3
	_branch_mesh = CylinderMesh.new()
	_branch_mesh.top_radius = 0.045
	_branch_mesh.bottom_radius = 0.07
	_branch_mesh.height = 1.0
	_branch_mesh.radial_segments = 6
	_flare_mesh = CylinderMesh.new()
	_flare_mesh.top_radius = 0.04
	_flare_mesh.bottom_radius = 0.12
	_flare_mesh.height = 0.8
	_flare_mesh.radial_segments = 6
	_vine_mesh = CylinderMesh.new()
	_vine_mesh.top_radius = 0.02
	_vine_mesh.bottom_radius = 0.035
	_vine_mesh.height = 1.0
	_vine_mesh.radial_segments = 5
	_bark_pool.append(_make_bark("bark_willow", Color(0.92, 0.88, 0.82), 1.6))
	_bark_pool.append(_make_bark("bark_willow", Color(0.78, 0.7, 0.62), 2.1))
	_bark_pool.append(_make_bark("bark_brown_01", Color(0.88, 0.82, 0.74), 1.5))
	_bark_pool.append(_make_bark("bark_brown_01", Color(0.7, 0.62, 0.52), 2.3))
	_leaf_pool.append(_make_leaf("forest_leaves_03", Color(0.58, 0.68, 0.42), 1.1))
	_leaf_pool.append(_make_leaf("forest_leaves_03", Color(0.42, 0.54, 0.3), 0.85))
	_leaf_pool.append(_make_leaf("leafy_grass", Color(0.5, 0.62, 0.36), 1.35))
	_leaf_pool.append(_make_leaf("leafy_grass", Color(0.34, 0.46, 0.24), 1.0))
	_leaf_pool.append(_make_leaf("forest_leaves_03", Color(0.62, 0.7, 0.4), 1.55))
	_rock_box = BoxMesh.new()
	_rock_box.size = Vector3.ONE
	var moss := MaterialLibrary.pbr("mossy_rock", 1.0)
	moss.albedo_color = Color(0.88, 0.9, 0.82)
	moss.roughness = 0.9
	_rock_pool.append(moss)
	var aerial := MaterialLibrary.pbr("aerial_rocks_02", 1.15)
	aerial.albedo_color = Color(0.86, 0.88, 0.8)
	aerial.roughness = 0.88
	_rock_pool.append(aerial)
	_litter_mat = MaterialLibrary.pbr("forest_leaves_03", 2.0)
	_litter_mat.albedo_color = Color(0.55, 0.48, 0.28)
	_litter_mat.roughness = 0.96
	_litter_mat.metallic = 0.0
	_litter_mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED


func _make_bark(stem: String, tint: Color, uv: float) -> StandardMaterial3D:
	var m := MaterialLibrary.pbr(stem, uv)
	m.albedo_color = tint
	m.roughness = 0.94
	m.metallic = 0.0
	return m


func _make_leaf(stem: String, tint: Color, uv: float) -> StandardMaterial3D:
	var m := MaterialLibrary.pbr(stem, uv)
	m.albedo_color = tint
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.roughness = 0.88
	m.metallic = 0.0
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	return m


func _bark_mat(rng: RandomNumberGenerator) -> StandardMaterial3D:
	return _bark_pool[rng.randi() % _bark_pool.size()]


func _leaf_mat(rng: RandomNumberGenerator) -> StandardMaterial3D:
	return _leaf_pool[rng.randi() % _leaf_pool.size()]


func _on_trail(x: float, z: float) -> bool:
	return abs(z) < 3.2 and x > -6.0 and x < 48.0


func _in_river(x: float, z: float) -> bool:
	return x > 18.0 and x < 34.0 and z > -14.0 and z < -4.0


func _near_landmark(x: float, z: float) -> bool:
	if x * x + z * z < 22.0:
		return true
	if (x - 24.5) * (x - 24.5) + (z - 12.0) * (z - 12.0) < 12.0:
		return true
	if (x - 12.5) * (x - 12.5) + z * z < 8.0:
		return true
	if (x - 33.8) * (x - 33.8) + (z + 8.5) * (z + 8.5) < 12.0:
		return true
	if (x + 16.0) * (x + 16.0) + (z + 10.0) * (z + 10.0) < 18.0:
		return true
	if (x - 26.0) * (x - 26.0) + (z + 9.0) * (z + 9.0) < 10.0:
		return true
	return false


func _environment() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var pano := PanoramaSkyMaterial.new()
	pano.panorama = load("res://assets/environment/hdris/rainforest_trail_1k.hdr")
	pano.energy_multiplier = 0.54
	sky.sky_material = pano
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.40
	e.ambient_light_sky_contribution = 0.72
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 0.78
	e.adjustment_enabled = true
	e.adjustment_saturation = 0.93
	e.fog_enabled = true
	e.fog_light_color = Color(0.50, 0.58, 0.45)
	e.fog_density = 0.0085
	e.fog_aerial_perspective = 0.58
	e.fog_sky_affect = 0.24
	e.fog_sun_scatter = 0.10
	e.glow_enabled = true
	e.glow_intensity = 0.028
	e.glow_bloom = 0.005
	env.environment = e
	add_child(env)


func _sun() -> void:
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 32, 0)
	sun.light_energy = 0.86
	sun.light_color = Color(1.0, 0.91, 0.74)
	sun.light_angular_distance = 1.05
	sun.shadow_enabled = true
	sun.shadow_bias = 0.045
	sun.shadow_normal_bias = 1.3
	sun.directional_shadow_max_distance = 62.0
	add_child(sun)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-18, -138, 0)
	fill.light_energy = 0.13
	fill.light_color = Color(0.42, 0.55, 0.52)
	fill.shadow_enabled = false
	add_child(fill)


func _terrain() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var res := 64
	var size := 92.0
	var step := size / float(res)
	var origin := -size * 0.5
	for iz in range(res):
		for ix in range(res):
			var x0 := origin + ix * step
			var z0 := origin + iz * step
			var x1 := x0 + step
			var z1 := z0 + step
			var p00 := Vector3(x0, height_at(x0, z0), z0)
			var p10 := Vector3(x1, height_at(x1, z0), z0)
			var p01 := Vector3(x0, height_at(x0, z1), z1)
			var p11 := Vector3(x1, height_at(x1, z1), z1)
			_tri(st, p00, p10, p11)
			_tri(st, p00, p11, p01)
	st.generate_normals()
	st.generate_tangents()
	var mesh := st.commit()
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = MaterialLibrary.terrain_blend()
	add_child(mi)
	var body := StaticBody3D.new()
	body.collision_layer = 1
	var col := CollisionShape3D.new()
	col.shape = mesh.create_trimesh_shape()
	body.add_child(col)
	add_child(body)
	_trail_dressing()


func _trail_dressing() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	for i in 14:
		var x := -2.0 + i * 3.4
		var z := sin(i * 0.7) * 0.45
		_rock(Vector3(x, height_at(x, z + 1.6), z + 1.6), rng, 0.35)
		if i % 2 == 0:
			_rock(Vector3(x + 0.8, height_at(x + 0.8, z - 1.5), z - 1.5), rng, 0.28)
	for i in 8:
		var x := 2.0 + i * 5.0
		var logm := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.05
		cyl.bottom_radius = 0.08
		cyl.height = rng.randf_range(0.9, 1.6)
		logm.mesh = cyl
		logm.material_override = _bark_pool[0]
		logm.position = Vector3(x, height_at(x, 1.8) + 0.08, 1.8)
		logm.rotation_degrees = Vector3(82, rng.randf() * 360.0, 8)
		add_child(logm)


func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	var n := (b - a).cross(c - a).normalized()
	st.set_normal(n)
	st.set_uv(Vector2(a.x * 0.12, a.z * 0.12))
	st.add_vertex(a)
	st.set_normal(n)
	st.set_uv(Vector2(b.x * 0.12, b.z * 0.12))
	st.add_vertex(b)
	st.set_normal(n)
	st.set_uv(Vector2(c.x * 0.12, c.z * 0.12))
	st.add_vertex(c)


func _water() -> void:
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode blend_mix, specular_schlick_ggx, cull_disabled, depth_draw_opaque;
uniform vec4 shallow : source_color = vec4(0.16, 0.34, 0.30, 0.78);
uniform vec4 deep : source_color = vec4(0.04, 0.12, 0.16, 0.92);
void vertex() {
	VERTEX.y += sin(TIME * 1.05 + VERTEX.x * 0.38 + VERTEX.z * 0.28) * 0.045;
	VERTEX.y += sin(TIME * 1.6 + VERTEX.z * 0.7) * 0.018;
}
void fragment() {
	float w = 0.5 + 0.5 * sin(UV.x * 18.0 + TIME * 0.5);
	float spec = 0.5 + 0.5 * sin(UV.y * 11.0 - TIME * 0.72);
	float shore = smoothstep(0.08, 0.42, abs(UV.x - 0.5) + abs(UV.y - 0.5) * 0.7);
	ALBEDO = mix(deep.rgb, shallow.rgb, w * spec * 0.65 + shore * 0.35);
	ROUGHNESS = 0.05 + spec * 0.1 + shore * 0.12;
	METALLIC = 0.04;
	SPECULAR = 0.72;
	ALPHA = mix(0.88, 0.72, shore);
	EMISSION = ALBEDO * 0.03;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = sh
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var res := 18
	for iz in range(res):
		for ix in range(res):
			var x0 := 17.5 + ix * (17.0 / res)
			var z0 := -15.5 + iz * (12.5 / res)
			var x1 := x0 + 17.0 / res
			var z1 := z0 + 12.5 / res
			if height_at((x0 + x1) * 0.5, (z0 + z1) * 0.5) > 0.12:
				continue
			var y := -0.22
			_tri(st, Vector3(x0, y, z0), Vector3(x1, y, z0), Vector3(x1, y, z1))
			_tri(st, Vector3(x0, y, z0), Vector3(x1, y, z1), Vector3(x0, y, z1))
	st.generate_normals()
	var mesh := st.commit()
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	add_child(mi)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var reed_mat := _leaf_pool[2] if _leaf_pool.size() > 2 else MaterialLibrary.pbr("leafy_grass", 2.0)
	for i in range(16):
		var x := 18.0 + rng.randf() * 16.0
		var z := -15.0 + rng.randf() * 12.0
		_rock(Vector3(x, height_at(x, z), z), rng, rng.randf_range(0.45, 0.95))
	for i in 10:
		var x := 19.0 + rng.randf() * 14.0
		var z := -14.5 + (0.0 if i % 2 == 0 else 11.0)
		var reed := MeshInstance3D.new()
		reed.mesh = _vine_mesh
		reed.material_override = reed_mat
		var reed_h := rng.randf_range(0.7, 1.3)
		reed.scale = Vector3(0.7, reed_h, 0.7)
		reed.position = Vector3(x, height_at(x, z) + reed_h * 0.45, z)
		add_child(reed)
	var bank_rng := RandomNumberGenerator.new()
	bank_rng.seed = 14
	for i in 8:
		var x := 18.5 + bank_rng.randf() * 15.0
		var z := -14.2 if i % 2 == 0 else -4.2
		var reed := MeshInstance3D.new()
		reed.mesh = _vine_mesh
		reed.material_override = reed_mat
		var reed_h := bank_rng.randf_range(0.55, 1.05)
		reed.scale = Vector3(0.85, reed_h, 0.85)
		reed.position = Vector3(x, height_at(x, z) + reed_h * 0.42, z)
		reed.rotation_degrees = Vector3(bank_rng.randf_range(-8, 8), bank_rng.randf() * 50.0, bank_rng.randf_range(-6, 6))
		reed.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(reed)
		if i % 2 == 0:
			_rock(Vector3(x, height_at(x, z), z), bank_rng, 0.32)


func _vegetation() -> void:
	var pos_rng := RandomNumberGenerator.new()
	pos_rng.seed = 88
	for i in range(55):
		var x := pos_rng.randf_range(-40, 44)
		var z := pos_rng.randf_range(-40, 40)
		if _on_trail(x, z) or _in_river(x, z) or _near_landmark(x, z):
			continue
		var vis := RandomNumberGenerator.new()
		vis.seed = 88011 + i * 131 + int(x * 17.0) + int(z * 29.0)
		_tree(Vector3(x, height_at(x, z), z), vis)
	var rock_rng := RandomNumberGenerator.new()
	rock_rng.seed = 31
	for i in range(30):
		var x := rock_rng.randf_range(-36, 42)
		var z := rock_rng.randf_range(-36, 36)
		if abs(z) < 2.5 and x > -4 and x < 46:
			continue
		if _near_landmark(x, z):
			continue
		_rock(Vector3(x, height_at(x, z), z), rock_rng)
	_grass_field()
	_tree_base_undergrowth()
	_path_frame_canopy()


func _tree(pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation_degrees.y = rng.randf() * 360.0
	var scale_mul := rng.randf_range(0.82, 1.38)
	root.scale = Vector3(scale_mul, rng.randf_range(0.88, 1.28), scale_mul)
	add_child(root)
	_tree_xz.append(Vector2(pos.x, pos.z))
	var bark := _bark_mat(rng)
	var leaf := _leaf_mat(rng)
	var trunk := CylinderMesh.new()
	trunk.top_radius = rng.randf_range(0.11, 0.26)
	trunk.bottom_radius = trunk.top_radius + rng.randf_range(0.05, 0.16)
	trunk.height = rng.randf_range(3.4, 7.2)
	trunk.radial_segments = 8
	var tmi := MeshInstance3D.new()
	tmi.mesh = trunk
	tmi.material_override = bark
	tmi.position = Vector3(0, trunk.height * 0.5, 0)
	tmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	root.add_child(tmi)
	var colb := StaticBody3D.new()
	colb.collision_layer = 1
	var cs := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = trunk.bottom_radius
	cyl.height = trunk.height
	cs.shape = cyl
	cs.position = tmi.position
	colb.add_child(cs)
	root.add_child(colb)
	if rng.randf() > 0.32:
		for b in 2:
			var br := MeshInstance3D.new()
			br.mesh = _branch_mesh
			br.material_override = bark
			var bh := rng.randf_range(0.85, 1.7)
			br.scale = Vector3(
				trunk.top_radius * 7.5,
				bh,
				trunk.top_radius * 7.5
			)
			br.position = Vector3(
				rng.randf_range(-0.18, 0.18),
				trunk.height * rng.randf_range(0.38, 0.78),
				0.12
			)
			br.rotation_degrees = Vector3(
				rng.randf_range(24, 62),
				rng.randf() * 360.0,
				rng.randf_range(-22, 22)
			)
			br.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			root.add_child(br)
	var clumps := 4 + rng.randi() % 3
	var canopy_base := trunk.height * rng.randf_range(0.86, 1.02)
	for k in range(clumps):
		var smi := MeshInstance3D.new()
		smi.mesh = _canopy_mesh
		smi.material_override = leaf if k % 3 != 2 else _leaf_mat(rng)
		var ang := TAU * float(k) / float(clumps) + rng.randf_range(-0.4, 0.4)
		var rad := rng.randf_range(0.12, 0.95)
		var layer := 0.0 if k < 3 else rng.randf_range(0.35, 0.95)
		smi.position = Vector3(
			cos(ang) * rad,
			canopy_base + rng.randf_range(-0.65, 0.55) + layer,
			sin(ang) * rad * rng.randf_range(0.75, 1.2)
		)
		smi.rotation_degrees = Vector3(
			rng.randf_range(48, 118),
			rng.randf() * 360.0,
			rng.randf_range(-36, 36)
		)
		smi.scale = Vector3(
			rng.randf_range(0.78, 1.42),
			rng.randf_range(0.62, 1.18),
			rng.randf_range(0.72, 1.38)
		)
		smi.cast_shadow = (
			GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			if k < 2
			else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		)
		root.add_child(smi)
	for r in range(3):
		var root_m := MeshInstance3D.new()
		root_m.mesh = _flare_mesh
		root_m.material_override = bark
		root_m.scale = Vector3(
			trunk.bottom_radius * 5.5,
			rng.randf_range(0.7, 1.25),
			trunk.bottom_radius * 5.5
		)
		root_m.position = Vector3(0, 0.08, 0)
		root_m.rotation_degrees = Vector3(78.0, r * 120.0 + rng.randf() * 24.0, rng.randf_range(-10, 10))
		root.add_child(root_m)
	if rng.randf() > 0.62:
		for v in range(2 + rng.randi() % 2):
			var vine := MeshInstance3D.new()
			vine.mesh = _vine_mesh
			vine.material_override = bark
			var vh := rng.randf_range(1.6, 2.8)
			vine.scale = Vector3(1.0, vh, 1.0)
			vine.position = Vector3(
				rng.randf_range(-0.4, 0.4),
				trunk.height * 0.45,
				rng.randf_range(0.2, 0.5)
			)
			vine.rotation_degrees = Vector3(12, rng.randf() * 50.0, rng.randf_range(-8, 8))
			root.add_child(vine)


func _rock(pos: Vector3, rng: RandomNumberGenerator, scale_mul: float = 1.0) -> void:
	var mat := _rock_pool[0]
	if rng.randf() <= 0.45:
		mat = _rock_pool[1]
	var cluster := Node3D.new()
	cluster.position = pos
	add_child(cluster)
	var chunks := 2 + rng.randi() % 2
	for i in chunks:
		var mi := MeshInstance3D.new()
		mi.mesh = _rock_box
		mi.material_override = mat
		mi.scale = Vector3(
			rng.randf_range(0.42, 1.15) * scale_mul,
			rng.randf_range(0.22, 0.48) * scale_mul,
			rng.randf_range(0.38, 1.05) * scale_mul
		)
		mi.position = Vector3(
			rng.randf_range(-0.28, 0.28) * scale_mul,
			mi.scale.y * rng.randf_range(0.22, 0.42),
			rng.randf_range(-0.28, 0.28) * scale_mul
		)
		mi.rotation_degrees = Vector3(rng.randf_range(-28, 28), rng.randf() * 360.0, rng.randf_range(-22, 22))
		mi.scale *= Vector3(rng.randf_range(0.85, 1.25), rng.randf_range(0.75, 1.15), rng.randf_range(0.85, 1.2))
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		cluster.add_child(mi)


func _grass_tuft_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var blades := 7
	for i in blades:
		var a := float(i) / float(blades) * TAU
		var lean := Vector3(cos(a) * 0.07, 0.0, sin(a) * 0.07)
		var tip := Vector3(cos(a) * 0.04, 0.42 + (i % 3) * 0.08, sin(a) * 0.04)
		var left := Vector3(cos(a + 0.18) * 0.05, 0.02, sin(a + 0.18) * 0.05)
		var right := Vector3(cos(a - 0.18) * 0.05, 0.02, sin(a - 0.18) * 0.05)
		st.add_vertex(lean)
		st.add_vertex(tip)
		st.add_vertex(left)
		st.add_vertex(lean)
		st.add_vertex(right)
		st.add_vertex(tip)
	st.generate_normals()
	return st.commit()


func _grass_field() -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = 380
	var tuft := _grass_tuft_mesh()
	var gmat := _leaf_pool[2]
	gmat.cull_mode = BaseMaterial3D.CULL_DISABLED
	var mi := MultiMeshInstance3D.new()
	mm.mesh = tuft
	mi.multimesh = mm
	mi.material_override = gmat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var placed := 0
	while placed < mm.instance_count:
		var x := rng.randf_range(-32, 42)
		var z := rng.randf_range(-32, 32)
		if absf(x) < 5.5 and z > 6.0 and z < 24.0:
			continue
		if abs(z) < 2.2 and x > -4.0 and x < 46.0:
			continue
		var xf := Transform3D.IDENTITY
		xf.basis = Basis.from_euler(Vector3(0.0, rng.randf() * TAU, 0.0)).scaled(
			Vector3(rng.randf_range(0.7, 1.45), rng.randf_range(0.65, 1.35), rng.randf_range(0.7, 1.45))
		)
		xf.origin = Vector3(x, height_at(x, z), z)
		mm.set_instance_transform(placed, xf)
		placed += 1
	_path_edge_grass(tuft, gmat)
	_leaf_litter()
	_bushes()
	_fallen_branches()


func _path_edge_grass(tuft: ArrayMesh, gmat: Material) -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = 88
	mm.mesh = tuft
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.material_override = gmat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	var rng := RandomNumberGenerator.new()
	rng.seed = 19
	var placed := 0
	var attempts := 0
	while placed < mm.instance_count and attempts < 400:
		attempts += 1
		var x := rng.randf_range(-3.5, 45.5)
		var z := (1.0 if placed % 2 == 0 else -1.0) * rng.randf_range(2.55, 4.35)
		if _near_landmark(x, z) or _in_river(x, z):
			continue
		var xf := Transform3D.IDENTITY
		xf.basis = Basis.from_euler(Vector3(0.0, rng.randf() * TAU, 0.0)).scaled(
			Vector3(rng.randf_range(0.85, 1.55), rng.randf_range(0.9, 1.55), rng.randf_range(0.85, 1.55))
		)
		xf.origin = Vector3(x, height_at(x, z), z)
		mm.set_instance_transform(placed, xf)
		placed += 1
	if placed < mm.instance_count:
		mm.instance_count = placed


func _leaf_litter() -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = 140
	var disc := CylinderMesh.new()
	disc.top_radius = 0.22
	disc.bottom_radius = 0.22
	disc.height = 0.028
	disc.radial_segments = 8
	var mat := _litter_mat
	var mi := MultiMeshInstance3D.new()
	mm.mesh = disc
	mi.multimesh = mm
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	var placed := 0
	var attempts := 0
	while placed < mm.instance_count and attempts < 480:
		attempts += 1
		var x := rng.randf_range(-28, 40)
		var z := rng.randf_range(-28, 28)
		if abs(z) < 2.0 and x > -2.0 and x < 46.0:
			continue
		if _in_river(x, z):
			continue
		var xf := Transform3D.IDENTITY
		xf.basis = Basis.from_euler(
			Vector3(rng.randf_range(-0.08, 0.08), rng.randf() * TAU, rng.randf_range(-0.08, 0.08))
		).scaled(Vector3(
			rng.randf_range(0.45, 2.05),
			1.0,
			rng.randf_range(0.45, 2.05)
		))
		xf.origin = Vector3(x, height_at(x, z) + 0.02, z)
		mm.set_instance_transform(placed, xf)
		placed += 1
	if placed < mm.instance_count:
		mm.instance_count = placed


func _bushes() -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = 72
	mm.mesh = _bush_mesh
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.material_override = _leaf_pool[3]
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	var rng := RandomNumberGenerator.new()
	rng.seed = 41
	var placed := 0
	var attempts := 0
	while placed < mm.instance_count and attempts < 360:
		attempts += 1
		var x := rng.randf_range(-32, 38)
		var z := rng.randf_range(-32, 30)
		if _on_trail(x, z) or _in_river(x, z) or _near_landmark(x, z):
			continue
		var xf := Transform3D.IDENTITY
		xf.basis = Basis.from_euler(Vector3(
			rng.randf_range(-0.25, 0.25),
			rng.randf() * TAU,
			rng.randf_range(-0.2, 0.2)
		)).scaled(Vector3(
			rng.randf_range(0.7, 1.45),
			rng.randf_range(0.45, 0.95),
			rng.randf_range(0.7, 1.4)
		))
		xf.origin = Vector3(x, height_at(x, z) + 0.12, z)
		mm.set_instance_transform(placed, xf)
		placed += 1
	if placed < mm.instance_count:
		mm.instance_count = placed


func _fallen_branches() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	var bark := _bark_pool[1]
	for i in 12:
		var x := rng.randf_range(-18, 20)
		var z := rng.randf_range(-18, 12)
		if _on_trail(x, z) or _in_river(x, z) or _near_landmark(x, z):
			continue
		var logm := MeshInstance3D.new()
		logm.mesh = _branch_mesh
		logm.material_override = bark
		var h := rng.randf_range(1.0, 2.1)
		logm.scale = Vector3(1.4, h, 1.4)
		logm.position = Vector3(x, height_at(x, z) + 0.1, z)
		logm.rotation_degrees = Vector3(88.0, rng.randf() * 360.0, rng.randf_range(-14, 14))
		add_child(logm)


func _tree_base_undergrowth() -> void:
	if _tree_xz.is_empty():
		return
	var count := mini(_tree_xz.size() * 3, 140)
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = count
	mm.mesh = _bush_mesh
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.material_override = _leaf_pool[0]
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	var rng := RandomNumberGenerator.new()
	rng.seed = 53
	var placed := 0
	for p in _tree_xz:
		if placed >= count:
			break
		for k in 3:
			if placed >= count:
				break
			var ang := rng.randf() * TAU
			var rad := rng.randf_range(0.5, 1.4)
			var x := p.x + cos(ang) * rad
			var z := p.y + sin(ang) * rad
			if _on_trail(x, z) or _in_river(x, z):
				continue
			var xf := Transform3D.IDENTITY
			xf.basis = Basis.from_euler(Vector3(
				rng.randf_range(-0.22, 0.22),
				rng.randf() * TAU,
				rng.randf_range(-0.18, 0.18)
			)).scaled(Vector3(
				rng.randf_range(0.5, 1.05),
				rng.randf_range(0.32, 0.72),
				rng.randf_range(0.5, 1.05)
			))
			xf.origin = Vector3(x, height_at(x, z) + 0.08, z)
			mm.set_instance_transform(placed, xf)
			placed += 1
	if placed < mm.instance_count:
		mm.instance_count = placed


func _path_frame_canopy() -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = 40
	mm.mesh = _canopy_mesh
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.material_override = _leaf_pool[1]
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	var rng := RandomNumberGenerator.new()
	rng.seed = 67
	var placed := 0
	var attempts := 0
	while placed < mm.instance_count and attempts < 220:
		attempts += 1
		var x := rng.randf_range(-2.0, 44.0)
		var z := (1.0 if placed % 2 == 0 else -1.0) * rng.randf_range(8.2, 15.5)
		if _near_landmark(x, z) or _in_river(x, z) or _on_trail(x, z):
			continue
		var xf := Transform3D.IDENTITY
		xf.basis = Basis.from_euler(Vector3(
			rng.randf_range(-0.45, 0.45),
			rng.randf() * TAU,
			rng.randf_range(-0.3, 0.3)
		)).scaled(Vector3(
			rng.randf_range(1.35, 2.15),
			rng.randf_range(0.85, 1.55),
			rng.randf_range(1.25, 2.05)
		))
		xf.origin = Vector3(x, height_at(x, z) + rng.randf_range(3.8, 6.8), z)
		mm.set_instance_transform(placed, xf)
		placed += 1
	if placed < mm.instance_count:
		mm.instance_count = placed


func _landmark() -> void:
	var giant := MeshInstance3D.new()
	giant.name = "LandmarkKapok"
	var trunk := CylinderMesh.new()
	trunk.top_radius = 0.85
	trunk.bottom_radius = 1.35
	trunk.height = 16.0
	giant.mesh = trunk
	giant.material_override = MaterialLibrary.pbr("bark_brown_01", 0.7)
	giant.position = Vector3(-16.0, height_at(-16.0, -10.0) + 8.0, -10.0)
	giant.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(giant)
	var leaf := _leaf_pool[1]
	var kapok_rng := RandomNumberGenerator.new()
	kapok_rng.seed = 44
	var cap_y := height_at(-16.0, -10.0) + 16.0
	for k in 6:
		var canopy := MeshInstance3D.new()
		canopy.mesh = _canopy_mesh
		canopy.material_override = leaf if k % 2 == 0 else _leaf_pool[0]
		var ang := TAU * float(k) / 6.0 + 0.18
		var rad := 1.1 + float(k % 3) * 0.55
		canopy.position = Vector3(
			-16.0 + cos(ang) * rad,
			cap_y + kapok_rng.randf_range(-0.8, 1.1),
			-10.0 + sin(ang) * rad * 0.85
		)
		canopy.rotation_degrees = Vector3(
			kapok_rng.randf_range(18, 72),
			kapok_rng.randf() * 360.0,
			kapok_rng.randf_range(-28, 28)
		)
		canopy.scale = Vector3(
			kapok_rng.randf_range(3.2, 4.4),
			kapok_rng.randf_range(1.8, 2.8),
			kapok_rng.randf_range(3.0, 4.2)
		)
		canopy.cast_shadow = (
			GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			if k < 2
			else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		)
		add_child(canopy)
	var stack := MeshInstance3D.new()
	stack.name = "RockFormation"
	var box := BoxMesh.new()
	box.size = Vector3(4.2, 3.4, 2.6)
	stack.mesh = box
	stack.material_override = MaterialLibrary.pbr("mossy_rock", 0.55)
	stack.position = Vector3(18.0, height_at(18.0, -14.0) + 1.55, -14.0)
	stack.rotation_degrees = Vector3(8.0, 22.0, -6.0)
	stack.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(stack)
	_bridge()


func _bridge() -> void:
	var wood := _bark_pool[0]
	var plank := BoxMesh.new()
	plank.size = Vector3(7.2, 0.14, 1.15)
	var mi := MeshInstance3D.new()
	mi.name = "RiverBridge"
	mi.mesh = plank
	mi.material_override = wood
	mi.position = Vector3(26.0, 0.22, -9.0)
	mi.rotation_degrees = Vector3(2.0, 18.0, 0.0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(mi)
	var rail := CylinderMesh.new()
	rail.top_radius = 0.035
	rail.bottom_radius = 0.045
	rail.height = 0.7
	rail.radial_segments = 6
	for k in 4:
		var post := MeshInstance3D.new()
		post.mesh = rail
		post.material_override = _bark_pool[1]
		var along := -2.4 if k < 2 else 2.4
		var side := -0.48 if k % 2 == 0 else 0.48
		var local := Vector3(along, 0.42, side)
		var rad := deg_to_rad(18.0)
		var rotated := Vector3(
			local.x * cos(rad) - local.z * sin(rad),
			local.y,
			local.x * sin(rad) + local.z * cos(rad)
		)
		post.position = Vector3(26.0, 0.22, -9.0) + rotated
		post.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(post)
	var beam := BoxMesh.new()
	beam.size = Vector3(7.0, 0.08, 0.12)
	for s in [-1.0, 1.0]:
		var edge := MeshInstance3D.new()
		edge.mesh = beam
		edge.material_override = _bark_pool[1]
		var local := Vector3(0, -0.04, 0.52 * s)
		var rad := deg_to_rad(18.0)
		var rotated := Vector3(
			local.x * cos(rad) - local.z * sin(rad),
			local.y,
			local.x * sin(rad) + local.z * cos(rad)
		)
		edge.position = Vector3(26.0, 0.22, -9.0) + rotated
		edge.rotation_degrees = Vector3(2.0, 18.0, 0.0)
		edge.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(edge)


func _atmosphere() -> void:
	var dust := GPUParticles3D.new()
	dust.name = "Motes"
	dust.amount = 36
	dust.lifetime = 8.0
	dust.preprocess = 3.0
	dust.visibility_aabb = AABB(Vector3(-40, 0, -40), Vector3(80, 18, 80))
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(28, 6, 28)
	mat.direction = Vector3(0.15, 0.05, 0.1)
	mat.spread = 40.0
	mat.initial_velocity_min = 0.04
	mat.initial_velocity_max = 0.16
	mat.gravity = Vector3(0, -0.02, 0)
	mat.scale_min = 0.04
	mat.scale_max = 0.1
	mat.color = Color(0.72, 0.80, 0.60, 0.22)
	dust.process_material = mat
	var pm := SphereMesh.new()
	pm.radius = 0.035
	pm.height = 0.07
	dust.draw_pass_1 = pm
	dust.position = Vector3(0, 4, 0)
	add_child(dust)


func _horizon() -> void:
	var hill_mat := MaterialLibrary.pbr("forest_ground_04", 0.08)
	hill_mat.albedo_color = Color(0.38, 0.44, 0.28)
	hill_mat.roughness = 0.92
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	for i in 8:
		var ang := float(i) / 8.0 * TAU + 0.2
		var dist := rng.randf_range(64.0, 84.0)
		var hill := MeshInstance3D.new()
		var sph := SphereMesh.new()
		sph.radius = rng.randf_range(12.0, 18.0)
		sph.radial_segments = 10
		sph.rings = 8
		hill.mesh = sph
		hill.material_override = hill_mat
		var sy := rng.randf_range(0.62, 0.95)
		var sx := rng.randf_range(1.15, 1.55)
		hill.scale = Vector3(sx, sy, sx * rng.randf_range(0.85, 1.1))
		hill.position = Vector3(
			cos(ang) * dist,
			sph.radius * sy * 0.22 - 2.4,
			sin(ang) * dist
		)
		hill.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(hill)
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = 84
	mm.mesh = _canopy_mesh
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.material_override = _leaf_pool[1]
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	for i in mm.instance_count:
		var ang := rng.randf() * TAU
		var far := i >= 48
		var dist := rng.randf_range(50.0, 74.0) if far else rng.randf_range(38.0, 54.0)
		var px := cos(ang) * dist
		var pz := sin(ang) * dist
		if not far and (_on_trail(px, pz) or _near_landmark(px, pz) or _in_river(px, pz)):
			dist = rng.randf_range(56.0, 76.0)
			px = cos(ang) * dist
			pz = sin(ang) * dist
			far = true
		var xf := Transform3D.IDENTITY
		xf.basis = Basis.from_euler(Vector3(
			rng.randf_range(-0.4, 0.4),
			rng.randf() * TAU,
			rng.randf_range(-0.28, 0.28)
		)).scaled(Vector3(
			rng.randf_range(2.1, 3.6) if far else rng.randf_range(1.5, 2.6),
			rng.randf_range(1.35, 2.4) if far else rng.randf_range(1.1, 1.9),
			rng.randf_range(2.0, 3.4) if far else rng.randf_range(1.45, 2.5)
		))
		var y := (5.2 + rng.randf_range(0.0, 4.8)) if far else (3.4 + rng.randf_range(0.0, 3.6))
		xf.origin = Vector3(px, y, pz)
		mm.set_instance_transform(i, xf)


func _camp() -> void:
	var hy := height_at(0, 0)
	var pad := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 3.2
	disc.bottom_radius = 3.2
	disc.height = 0.05
	pad.mesh = disc
	pad.material_override = MaterialLibrary.pbr("brown_mud_03", 2.4)
	pad.position = Vector3(0, hy + 0.03, 0)
	add_child(pad)
	var pit := MeshInstance3D.new()
	var pitm := CylinderMesh.new()
	pitm.top_radius = 0.55
	pitm.bottom_radius = 0.62
	pitm.height = 0.08
	pit.mesh = pitm
	var pitmat := MaterialLibrary.pbr("brown_mud_03", 3.0)
	pitmat.albedo_color = Color(0.22, 0.14, 0.1)
	pit.material_override = pitmat
	pit.position = Vector3(0, hy + 0.05, 0)
	add_child(pit)
	for i in range(10):
		var ang := i * TAU / 10.0
		var mi := MeshInstance3D.new()
		mi.mesh = _rock_box
		mi.material_override = _rock_pool[i % 2]
		mi.scale = Vector3(0.28 + (i % 3) * 0.04, 0.12 + (i % 2) * 0.04, 0.2)
		var rad := 0.68 + float(i % 3) * 0.04
		mi.position = Vector3(cos(ang) * rad, hy + 0.055, sin(ang) * rad)
		mi.rotation_degrees = Vector3(float((i * 13) % 24) - 12.0, float(i) * 37.0, float((i * 9) % 18) - 9.0)
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(mi)
	var fire_log := CylinderMesh.new()
	fire_log.top_radius = 0.035
	fire_log.bottom_radius = 0.05
	fire_log.height = 0.62
	fire_log.radial_segments = 6
	var fire_bark := _bark_pool[2]
	for i in 5:
		var logm := MeshInstance3D.new()
		logm.mesh = fire_log
		logm.material_override = fire_bark
		logm.position = Vector3(0, hy + 0.2, 0)
		logm.rotation_degrees = Vector3(58, i * 72.0, 8)
		logm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(logm)
	var fire := OmniLight3D.new()
	fire.light_color = Color(1.0, 0.5, 0.18)
	fire.light_energy = 0.85
	fire.omni_range = 4.6
	fire.shadow_enabled = false
	fire.position = Vector3(0, hy + 0.62, 0)
	add_child(fire)
	var flame := MeshInstance3D.new()
	var flm := SphereMesh.new()
	flm.radius = 0.12
	flame.mesh = flm
	var flmat := StandardMaterial3D.new()
	flmat.albedo_color = Color(1.0, 0.45, 0.12, 0.55)
	flmat.emission_enabled = true
	flmat.emission = Color(1.0, 0.35, 0.08)
	flmat.emission_energy_multiplier = 1.6
	flmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flmat.roughness = 1.0
	flame.material_override = flmat
	flame.position = Vector3(0, hy + 0.32, 0)
	flame.scale = Vector3(0.7, 1.4, 0.7)
	flame.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(flame)
	var embers := GPUParticles3D.new()
	embers.amount = 16
	embers.lifetime = 1.35
	embers.position = Vector3(0, hy + 0.28, 0)
	var epm := ParticleProcessMaterial.new()
	epm.direction = Vector3(0, 1, 0)
	epm.spread = 18.0
	epm.initial_velocity_min = 0.15
	epm.initial_velocity_max = 0.45
	epm.gravity = Vector3(0, 0.2, 0)
	epm.scale_min = 0.02
	epm.scale_max = 0.05
	epm.color = Color(1.0, 0.45, 0.12, 0.7)
	embers.process_material = epm
	var es := SphereMesh.new()
	es.radius = 0.03
	es.height = 0.06
	embers.draw_pass_1 = es
	add_child(embers)
	var canvas := MaterialLibrary.fabric(Color(0.66, 0.55, 0.38), 2.6)
	var canvas_shade := MaterialLibrary.fabric(Color(0.52, 0.42, 0.28), 3.1)
	var canvas_flap := MaterialLibrary.fabric(Color(0.44, 0.34, 0.22), 2.2)
	var poles := _bark_pool[2]
	var tent_root := Node3D.new()
	tent_root.position = Vector3(-3.3, hy, -2.5)
	add_child(tent_root)
	var ridge := MeshInstance3D.new()
	var ridgem := CylinderMesh.new()
	ridgem.top_radius = 0.03
	ridgem.bottom_radius = 0.03
	ridgem.height = 2.4
	ridge.mesh = ridgem
	ridge.material_override = poles
	ridge.position = Vector3(0, 1.55, 0)
	ridge.rotation_degrees = Vector3(0, 0, 90)
	tent_root.add_child(ridge)
	var crease := MeshInstance3D.new()
	var creasem := BoxMesh.new()
	creasem.size = Vector3(2.32, 0.025, 0.08)
	crease.mesh = creasem
	crease.material_override = canvas_shade
	crease.position = Vector3(0, 1.48, 0)
	tent_root.add_child(crease)
	var wall_mesh := BoxMesh.new()
	wall_mesh.size = Vector3(2.4, 0.04, 1.85)
	var fold_mesh := BoxMesh.new()
	fold_mesh.size = Vector3(2.15, 0.02, 0.55)
	for side in [-1.0, 1.0]:
		var wall := MeshInstance3D.new()
		wall.mesh = wall_mesh
		wall.material_override = canvas if side < 0.0 else canvas_shade
		wall.position = Vector3(0, 0.78, 0.62 * side)
		wall.rotation_degrees = Vector3(38.0 * side, 0, 0)
		wall.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		tent_root.add_child(wall)
		var fold := MeshInstance3D.new()
		fold.mesh = fold_mesh
		fold.material_override = canvas_flap
		fold.position = Vector3(0.08 * side, 0.92, 0.58 * side)
		fold.rotation_degrees = Vector3(42.0 * side, 4.0 * side, 0)
		fold.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		tent_root.add_child(fold)
		var pole := MeshInstance3D.new()
		var pm := CylinderMesh.new()
		pm.top_radius = 0.025
		pm.bottom_radius = 0.03
		pm.height = 1.7
		pole.mesh = pm
		pole.material_override = poles
		pole.position = Vector3(1.05 * side, 0.82, 0.05)
		tent_root.add_child(pole)
	var flap := MeshInstance3D.new()
	var flapm := BoxMesh.new()
	flapm.size = Vector3(0.035, 1.08, 0.82)
	flap.mesh = flapm
	flap.material_override = canvas_flap
	flap.position = Vector3(1.18, 0.64, 0.18)
	flap.rotation_degrees = Vector3(6, -32, 8)
	tent_root.add_child(flap)
	var flap_in := MeshInstance3D.new()
	flap_in.mesh = flapm
	flap_in.material_override = canvas_shade
	flap_in.position = Vector3(1.08, 0.6, -0.16)
	flap_in.rotation_degrees = Vector3(-4, 18, -6)
	flap_in.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	tent_root.add_child(flap_in)
	var peg_mesh := CylinderMesh.new()
	peg_mesh.top_radius = 0.012
	peg_mesh.bottom_radius = 0.016
	peg_mesh.height = 0.18
	var rope_mesh := CylinderMesh.new()
	rope_mesh.top_radius = 0.008
	rope_mesh.bottom_radius = 0.008
	rope_mesh.height = 1.15
	for i in 4:
		var peg := MeshInstance3D.new()
		peg.mesh = peg_mesh
		peg.material_override = poles
		var sx := -1.0 if i < 2 else 1.0
		var sz := -1.0 if i % 2 == 0 else 1.0
		peg.position = Vector3(1.15 * sx, 0.08, 0.85 * sz)
		peg.rotation_degrees = Vector3(18 * sz, 0, 12 * sx)
		tent_root.add_child(peg)
		var rope := MeshInstance3D.new()
		rope.mesh = rope_mesh
		rope.material_override = poles
		rope.position = Vector3(0.7 * sx, 0.7, 0.45 * sz)
		rope.rotation_degrees = Vector3(32 * sz, 0, -28 * sx)
		tent_root.add_child(rope)
	var crate := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.7, 0.5, 0.7)
	crate.mesh = box
	crate.material_override = _bark_pool[0]
	crate.position = Vector3(-1.5, hy + 0.26, -1.7)
	crate.rotation_degrees = Vector3(0, 16, 0)
	crate.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(crate)
	var band_mesh := BoxMesh.new()
	band_mesh.size = Vector3(0.74, 0.04, 0.08)
	for b in 2:
		var band := MeshInstance3D.new()
		band.mesh = band_mesh
		band.material_override = canvas_flap
		band.position = Vector3(-1.5, hy + 0.18 + b * 0.18, -1.7)
		band.rotation_degrees = Vector3(0, 16, 0)
		band.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(band)
	var lid := MeshInstance3D.new()
	var lidm := BoxMesh.new()
	lidm.size = Vector3(0.72, 0.04, 0.72)
	lid.mesh = lidm
	lid.material_override = _bark_pool[1]
	lid.position = Vector3(-1.5, hy + 0.52, -1.7)
	lid.rotation_degrees = Vector3(2, 16, 0)
	add_child(lid)
	var bed := MeshInstance3D.new()
	var bedm := BoxMesh.new()
	bedm.size = Vector3(1.4, 0.07, 0.55)
	bed.mesh = bedm
	bed.material_override = canvas_shade
	bed.position = Vector3(-2.6, hy + 0.08, -0.6)
	bed.rotation_degrees = Vector3(0, 8, 0)
	add_child(bed)
	var roll := MeshInstance3D.new()
	var rollm := CylinderMesh.new()
	rollm.top_radius = 0.09
	rollm.bottom_radius = 0.09
	rollm.height = 0.52
	roll.mesh = rollm
	roll.material_override = canvas
	roll.position = Vector3(-3.18, hy + 0.14, -0.58)
	roll.rotation_degrees = Vector3(0, 0, 90)
	add_child(roll)
	var stump := MeshInstance3D.new()
	var stc := CylinderMesh.new()
	stc.top_radius = 0.28
	stc.bottom_radius = 0.32
	stc.height = 0.42
	stump.mesh = stc
	stump.material_override = _bark_pool[2]
	stump.position = Vector3(1.6, hy + 0.21, -1.1)
	add_child(stump)
	var rings := MeshInstance3D.new()
	var ringm := CylinderMesh.new()
	ringm.top_radius = 0.26
	ringm.bottom_radius = 0.26
	ringm.height = 0.03
	rings.mesh = ringm
	rings.material_override = canvas_flap
	rings.position = Vector3(1.6, hy + 0.43, -1.1)
	add_child(rings)
	var lantern := OmniLight3D.new()
	lantern.light_color = Color(1.0, 0.78, 0.45)
	lantern.light_energy = 0.35
	lantern.omni_range = 2.4
	lantern.shadow_enabled = false
	lantern.position = Vector3(-1.5, hy + 0.7, -1.7)
	add_child(lantern)
	for i in 4:
		var ang := i * TAU / 4.0 + 0.4
		_rock(Vector3(cos(ang) * 3.4, hy, sin(ang) * 3.4), RandomNumberGenerator.new(), 0.55)


func _fallen_tree() -> FallenTree:
	var t := FallenTree.new()
	t.position = Vector3(12.5, height_at(12.5, 0) + 0.1, 0)
	add_child(t)
	return t


func _climb() -> ClimbLedge:
	var c := ClimbLedge.new()
	c.position = Vector3(24.5, height_at(24.5, 12), 12)
	add_child(c)
	return c


func _gap_wall() -> StaticBody3D:
	var wall := StaticBody3D.new()
	wall.collision_layer = 16
	wall.collision_mask = 0
	var box := BoxShape3D.new()
	box.size = Vector3(2.2, 3.2, 8.0)
	var col := CollisionShape3D.new()
	col.shape = box
	col.position = Vector3(0, 1.6, 0)
	wall.add_child(col)
	wall.position = Vector3(31.5, height_at(31.5, -7), -7)
	add_child(wall)
	var rng := RandomNumberGenerator.new()
	rng.seed = 61
	var wall_mat := MaterialLibrary.pbr("rock_wall_02", 0.65)
	var moss := MaterialLibrary.pbr("aerial_rocks_02", 0.7)
	for i in 8:
		var side := -1.0 if i < 4 else 1.0
		var mi := MeshInstance3D.new()
		var sph := SphereMesh.new()
		sph.radius = rng.randf_range(0.7, 1.4)
		mi.mesh = sph
		mi.material_override = wall_mat if i % 2 == 0 else moss
		var z := -7.0 + side * 2.8 + rng.randf_range(-0.4, 0.4)
		mi.position = Vector3(31.5 + rng.randf_range(-0.4, 0.4), height_at(31.5, z) + rng.randf_range(0.8, 1.8), z)
		mi.scale = Vector3(rng.randf_range(1.1, 1.7), rng.randf_range(0.7, 1.3), rng.randf_range(1.0, 1.5))
		mi.rotation_degrees = Vector3(rng.randf_range(-18, 18), rng.randf() * 360.0, rng.randf_range(-12, 12))
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		add_child(mi)
	for i in 6:
		var vine := MeshInstance3D.new()
		var vc := CylinderMesh.new()
		vc.top_radius = 0.025
		vc.bottom_radius = 0.04
		vc.height = rng.randf_range(1.5, 2.6)
		vine.mesh = vc
		vine.material_override = MaterialLibrary.pbr("bark_willow", 2.4)
		vine.position = Vector3(31.5, height_at(31.5, -7.0) + 2.2, -7.0 + rng.randf_range(-2.2, 2.2))
		vine.rotation_degrees = Vector3(8, 0, rng.randf_range(-10, 10))
		add_child(vine)
	return wall


func _coil() -> CoilPost:
	var p := CoilPost.new()
	p.position = Vector3(33.8, height_at(33.8, -8.5) + 0.05, -8.5)
	add_child(p)
	return p


func _vine_gate() -> Node3D:
	var g := Node3D.new()
	g.position = Vector3(38.5, height_at(38.5, 0), 0)
	var leaf := MaterialLibrary.pbr("forest_leaves_03", 1.0)
	leaf.albedo_color = Color(0.4, 0.52, 0.28)
	var bark := MaterialLibrary.pbr("bark_willow", 1.8)
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	for i in 16:
		var vine := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = rng.randf_range(0.04, 0.08)
		cyl.bottom_radius = rng.randf_range(0.06, 0.11)
		cyl.height = rng.randf_range(3.6, 5.0)
		vine.mesh = cyl
		vine.material_override = bark if i % 3 == 0 else leaf
		vine.position = Vector3(rng.randf_range(-0.35, 0.35), cyl.height * 0.45, rng.randf_range(-3.1, 3.1))
		vine.rotation_degrees = Vector3(rng.randf_range(-8, 8), rng.randf() * 30.0, rng.randf_range(-10, 10))
		vine.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		g.add_child(vine)
	for i in 8:
		var tuft := MeshInstance3D.new()
		tuft.mesh = _bush_mesh
		tuft.material_override = leaf
		tuft.position = Vector3(rng.randf_range(-0.3, 0.3), rng.randf_range(1.2, 3.8), rng.randf_range(-3.0, 3.0))
		tuft.scale = Vector3(rng.randf_range(0.9, 1.25), rng.randf_range(0.85, 1.2), rng.randf_range(0.85, 1.15))
		tuft.rotation_degrees = Vector3(rng.randf_range(-16, 16), rng.randf() * 360.0, rng.randf_range(-10, 10))
		tuft.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		g.add_child(tuft)
	var body := StaticBody3D.new()
	body.collision_layer = 1
	var col := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = Vector3(1.2, 4.5, 7.0)
	col.shape = sh
	col.position = Vector3(0, 2.2, 0)
	body.add_child(col)
	g.add_child(body)
	add_child(g)
	return g


func _explorer() -> ExplorerMarker:
	var e := ExplorerMarker.new()
	e.position = Vector3(44.5, height_at(44.5, 0) + 0.1, 0)
	add_child(e)
	return e
