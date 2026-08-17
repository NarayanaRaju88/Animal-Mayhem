class_name JungleBuilder
extends Node3D
## Builds a compact jungle slice: camp, forest, river, rocks, blocked path.


func build() -> Dictionary:
	_environment()
	_sun()
	_terrain()
	_water()
	_vegetation()
	_landmark()
	_atmosphere()
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


func _environment() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var pano := PanoramaSkyMaterial.new()
	pano.panorama = load("res://assets/environment/hdris/rainforest_trail_1k.hdr")
	pano.energy_multiplier = 0.85
	sky.sky_material = pano
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.52
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 0.92
	e.adjustment_enabled = true
	e.adjustment_saturation = 0.96
	e.fog_enabled = true
	e.fog_light_color = Color(0.58, 0.62, 0.5)
	e.fog_density = 0.0075
	e.fog_aerial_perspective = 0.55
	e.fog_sky_affect = 0.35
	e.glow_enabled = true
	e.glow_intensity = 0.12
	e.glow_bloom = 0.02
	env.environment = e
	add_child(env)


func _sun() -> void:
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, 38, 0)
	sun.light_energy = 1.05
	sun.light_color = Color(1.0, 0.93, 0.78)
	sun.light_angular_distance = 0.6
	sun.shadow_enabled = true
	sun.shadow_bias = 0.04
	sun.shadow_normal_bias = 1.2
	sun.directional_shadow_max_distance = 70.0
	add_child(sun)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-20, -140, 0)
	fill.light_energy = 0.18
	fill.light_color = Color(0.55, 0.65, 0.7)
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
	var mat := MaterialLibrary.pbr("forest_ground_04", 0.12)
	mat.uv1_scale = Vector3(0.12, 0.12, 0.12)
	mat.uv1_triplanar = true
	mat.uv1_world_triplanar = true
	mat.uv1_triplanar_sharpness = 4.0
	mi.material_override = mat
	add_child(mi)
	var body := StaticBody3D.new()
	body.collision_layer = 1
	var col := CollisionShape3D.new()
	col.shape = mesh.create_trimesh_shape()
	body.add_child(col)
	add_child(body)
	var path := BoxMesh.new()
	path.size = Vector3(52, 0.07, 3.6)
	var pmi := MeshInstance3D.new()
	pmi.mesh = path
	var pm := MaterialLibrary.pbr("grass_path_3", 3.0)
	pmi.material_override = pm
	pmi.position = Vector3(16, 0.24, 0)
	add_child(pmi)


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
uniform vec4 shallow : source_color = vec4(0.14, 0.32, 0.30, 0.78);
uniform vec4 deep : source_color = vec4(0.05, 0.14, 0.18, 0.9);
void vertex() {
	VERTEX.y += sin(TIME * 1.1 + VERTEX.x * 0.45 + VERTEX.z * 0.3) * 0.05;
	VERTEX.y += sin(TIME * 1.7 + VERTEX.z * 0.8) * 0.02;
}
void fragment() {
	float w = 0.5 + 0.5 * sin(UV.x * 22.0 + TIME * 0.55);
	float spec = 0.5 + 0.5 * sin(UV.y * 14.0 - TIME * 0.8);
	ALBEDO = mix(deep.rgb, shallow.rgb, w * spec);
	ROUGHNESS = 0.06 + spec * 0.08;
	METALLIC = 0.08;
	SPECULAR = 0.7;
	ALPHA = 0.82;
	EMISSION = ALBEDO * 0.035;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = sh
	var plane := PlaneMesh.new()
	plane.size = Vector2(20, 13)
	plane.subdivide_width = 32
	plane.subdivide_depth = 20
	var mi := MeshInstance3D.new()
	mi.mesh = plane
	mi.material_override = mat
	mi.position = Vector3(26, -0.28, -9)
	add_child(mi)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for i in range(10):
		var x := 18.0 + rng.randf() * 16.0
		var z := -15.0 + rng.randf() * 12.0
		_rock(Vector3(x, height_at(x, z), z), rng, 0.7)


func _vegetation() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 88
	for i in range(55):
		var x := rng.randf_range(-40, 44)
		var z := rng.randf_range(-40, 40)
		if abs(z) < 3.2 and x > -6 and x < 48:
			continue
		if x > 18 and x < 34 and z > -14 and z < -4:
			continue
		_tree(Vector3(x, height_at(x, z), z), rng)
	for i in range(30):
		var x := rng.randf_range(-36, 42)
		var z := rng.randf_range(-36, 36)
		if abs(z) < 2.5 and x > -4 and x < 46:
			continue
		_rock(Vector3(x, height_at(x, z), z), rng)
	_grass_field()


func _tree(pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation_degrees.y = rng.randf() * 360.0
	var scale_mul := rng.randf_range(0.78, 1.45)
	root.scale = Vector3(scale_mul, rng.randf_range(0.85, 1.35), scale_mul)
	add_child(root)
	var bark_stem := "bark_willow" if rng.randf() > 0.45 else "bark_brown_01"
	var bark := MaterialLibrary.pbr(bark_stem, rng.randf_range(1.4, 2.4))
	bark.albedo_color = Color(0.92, 0.88, 0.82).darkened(rng.randf() * 0.18)
	var leaf := MaterialLibrary.pbr("leafy_grass", rng.randf_range(0.8, 1.6))
	leaf.albedo_color = Color(0.62, 0.72, 0.48).lightened(rng.randf() * 0.12)
	leaf.cull_mode = BaseMaterial3D.CULL_DISABLED
	var trunk := CylinderMesh.new()
	trunk.top_radius = rng.randf_range(0.12, 0.24)
	trunk.bottom_radius = trunk.top_radius + rng.randf_range(0.06, 0.14)
	trunk.height = rng.randf_range(3.2, 6.4)
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
	var clumps := 2 + rng.randi() % 3
	for k in range(clumps):
		var sph := SphereMesh.new()
		sph.radius = rng.randf_range(1.05, 1.85)
		var smi := MeshInstance3D.new()
		smi.mesh = sph
		smi.material_override = leaf
		smi.position = Vector3(
			rng.randf_range(-0.85, 0.85),
			trunk.height + rng.randf_range(-0.35, 0.65),
			rng.randf_range(-0.85, 0.85)
		)
		smi.scale = Vector3(rng.randf_range(0.85, 1.25), rng.randf_range(0.65, 1.05), rng.randf_range(0.85, 1.25))
		smi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		root.add_child(smi)


func _rock(pos: Vector3, rng: RandomNumberGenerator, scale_mul: float = 1.0) -> void:
	var mat := MaterialLibrary.pbr("mossy_rock", rng.randf_range(0.7, 1.4))
	mat.albedo_color = Color(0.88, 0.9, 0.82)
	var box := SphereMesh.new()
	box.radius = rng.randf_range(0.4, 1.15) * scale_mul
	var mi := MeshInstance3D.new()
	mi.mesh = box
	mi.material_override = mat
	mi.position = pos + Vector3(0, box.radius * 0.35, 0)
	mi.rotation_degrees = Vector3(rng.randf_range(-24, 24), rng.randf() * 360.0, rng.randf_range(-24, 24))
	mi.scale = Vector3(rng.randf_range(0.85, 1.3), rng.randf_range(0.42, 0.82), rng.randf_range(0.9, 1.35))
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(mi)


func _grass_field() -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = 480
	var blade := QuadMesh.new()
	blade.size = Vector2(0.55, 0.72)
	var gmat := MaterialLibrary.pbr("leafy_grass", 1.0)
	gmat.cull_mode = BaseMaterial3D.CULL_DISABLED
	gmat.albedo_color = Color(0.72, 0.82, 0.52)
	blade.material = gmat
	var mi := MultiMeshInstance3D.new()
	mm.mesh = blade
	mi.multimesh = mm
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
		xf.origin = Vector3(x, height_at(x, z) + 0.34, z)
		xf.basis = Basis.from_euler(Vector3(0.0, rng.randf() * TAU, 0.0)).scaled(
			Vector3(rng.randf_range(0.7, 1.55), rng.randf_range(0.75, 1.6), 1.0)
		)
		mm.set_instance_transform(placed, xf)
		placed += 1
	_bushes()
	_fallen_branches()


func _bushes() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 41
	for i in 26:
		var x := rng.randf_range(-32, 38)
		var z := rng.randf_range(-32, 30)
		if abs(z) < 3.0 and x > -6.0 and x < 48.0:
			continue
		var b := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = rng.randf_range(0.42, 0.95)
		sm.height = rng.randf_range(0.65, 1.25)
		b.mesh = sm
		var mat := MaterialLibrary.pbr("leafy_grass", 1.2)
		mat.albedo_color = Color(0.38, 0.48, 0.26)
		b.material_override = mat
		b.position = Vector3(x, height_at(x, z) + 0.28, z)
		b.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		add_child(b)


func _fallen_branches() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	for i in 9:
		var x := rng.randf_range(-18, 20)
		var z := rng.randf_range(-18, 12)
		var logm := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.06
		cyl.bottom_radius = 0.1
		cyl.height = rng.randf_range(1.0, 2.1)
		logm.mesh = cyl
		logm.material_override = MaterialLibrary.pbr("bark_willow", 1.6)
		logm.position = Vector3(x, height_at(x, z) + 0.1, z)
		logm.rotation_degrees = Vector3(88.0, rng.randf() * 360.0, rng.randf_range(-14, 14))
		add_child(logm)


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
	var canopy := MeshInstance3D.new()
	var sph := SphereMesh.new()
	sph.radius = 5.5
	sph.height = 7.5
	canopy.mesh = sph
	var leaf := MaterialLibrary.pbr("leafy_grass", 0.5)
	leaf.albedo_color = Color(0.32, 0.44, 0.2)
	canopy.material_override = leaf
	canopy.position = Vector3(-16.0, height_at(-16.0, -10.0) + 16.0, -10.0)
	canopy.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
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
	var plank := BoxMesh.new()
	plank.size = Vector3(7.2, 0.14, 1.15)
	var mi := MeshInstance3D.new()
	mi.name = "RiverBridge"
	mi.mesh = plank
	mi.material_override = MaterialLibrary.pbr("bark_willow", 2.2)
	mi.position = Vector3(26.0, 0.22, -9.0)
	mi.rotation_degrees = Vector3(2.0, 18.0, 0.0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(mi)


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
	mat.color = Color(0.85, 0.9, 0.7, 0.32)
	dust.process_material = mat
	var pm := SphereMesh.new()
	pm.radius = 0.035
	pm.height = 0.07
	dust.draw_pass_1 = pm
	dust.position = Vector3(0, 4, 0)
	add_child(dust)


func _camp() -> void:
	var stone := MaterialLibrary.pbr("mossy_rock", 1.8)
	for i in range(8):
		var ang := i * TAU / 8.0
		var sph := SphereMesh.new()
		sph.radius = 0.18
		var mi := MeshInstance3D.new()
		mi.mesh = sph
		mi.material_override = stone
		mi.position = Vector3(cos(ang) * 0.7, height_at(0, 0) + 0.12, sin(ang) * 0.7)
		add_child(mi)
	var fire := OmniLight3D.new()
	fire.light_color = Color(1.0, 0.55, 0.2)
	fire.light_energy = 1.15
	fire.omni_range = 5.5
	fire.shadow_enabled = false
	fire.position = Vector3(0, 0.8, 0)
	add_child(fire)
	var tent := PrismMesh.new()
	tent.size = Vector3(2.4, 1.6, 2.2)
	var canvas := StandardMaterial3D.new()
	canvas.albedo_color = Color(0.62, 0.5, 0.34)
	canvas.roughness = 0.92
	canvas.metallic = 0.0
	var tmi := MeshInstance3D.new()
	tmi.mesh = tent
	tmi.material_override = canvas
	tmi.position = Vector3(-3.2, 0.95, -2.4)
	tmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(tmi)
	var crate := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.7, 0.55, 0.7)
	crate.mesh = box
	crate.material_override = MaterialLibrary.pbr("bark_willow", 1.4)
	crate.position = Vector3(-1.6, height_at(-1.6, -1.8) + 0.28, -1.8)
	crate.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(crate)


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
	var rock := MaterialLibrary.pbr("mossy_rock", 0.7)
	var left := BoxMesh.new()
	left.size = Vector3(2.4, 3.4, 3.1)
	var mi := MeshInstance3D.new()
	mi.mesh = left
	mi.material_override = rock
	mi.position = Vector3(31.5, height_at(31.5, -4.2) + 1.7, -4.2)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(mi)
	var mi2 := MeshInstance3D.new()
	mi2.mesh = left.duplicate()
	mi2.material_override = rock
	mi2.position = Vector3(31.5, height_at(31.5, -10.2) + 1.7, -10.2)
	mi2.rotation_degrees = Vector3(0, 12, 4)
	mi2.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(mi2)
	return wall


func _coil() -> CoilPost:
	var p := CoilPost.new()
	p.position = Vector3(33.8, height_at(33.8, -8.5) + 0.05, -8.5)
	add_child(p)
	return p


func _vine_gate() -> Node3D:
	var g := Node3D.new()
	g.position = Vector3(38.5, height_at(38.5, 0), 0)
	var mat := MaterialLibrary.pbr("leafy_grass", 1.1)
	mat.albedo_color = Color(0.28, 0.42, 0.18)
	var box := BoxMesh.new()
	box.size = Vector3(1.2, 4.5, 7.0)
	var mi := MeshInstance3D.new()
	mi.mesh = box
	mi.material_override = mat
	mi.position = Vector3(0, 2.2, 0)
	g.add_child(mi)
	var body := StaticBody3D.new()
	body.collision_layer = 1
	var col := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = box.size
	col.shape = sh
	col.position = mi.position
	body.add_child(col)
	g.add_child(body)
	add_child(g)
	return g


func _explorer() -> ExplorerMarker:
	var e := ExplorerMarker.new()
	e.position = Vector3(44.5, height_at(44.5, 0) + 0.1, 0)
	add_child(e)
	return e
