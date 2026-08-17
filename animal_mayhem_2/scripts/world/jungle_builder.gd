class_name JungleBuilder
extends Node3D
## Builds a compact jungle slice: camp, forest, river, rocks, blocked path.


func build() -> Dictionary:
	_environment()
	_sun()
	_terrain()
	_water()
	_vegetation()
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
	var mat := ProceduralSkyMaterial.new()
	mat.sky_top_color = Color(0.42, 0.62, 0.78)
	mat.sky_horizon_color = Color(0.78, 0.72, 0.52)
	mat.ground_bottom_color = Color(0.12, 0.18, 0.1)
	mat.ground_horizon_color = Color(0.32, 0.38, 0.22)
	mat.sun_angle_max = 28.0
	sky.sky_material = mat
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.42
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.adjustment_enabled = true
	e.adjustment_saturation = 1.05
	e.fog_enabled = true
	e.fog_light_color = Color(0.55, 0.62, 0.48)
	e.fog_density = 0.012
	e.fog_aerial_perspective = 0.4
	e.glow_enabled = true
	e.glow_intensity = 0.25
	e.ssao_enabled = false
	env.environment = e
	add_child(env)


func _sun() -> void:
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, 35, 0)
	sun.light_energy = 1.15
	sun.light_color = Color(1.0, 0.95, 0.82)
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 80.0
	add_child(sun)


func _terrain() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var res := 56
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
	var mesh := st.commit()
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.27, 0.38, 0.18)
	mat.roughness = 0.92
	mat.vertex_color_use_as_albedo = false
	mi.material_override = mat
	add_child(mi)
	var body := StaticBody3D.new()
	body.collision_layer = 1
	var col := CollisionShape3D.new()
	col.shape = mesh.create_trimesh_shape()
	body.add_child(col)
	add_child(body)
	# path dirt strip
	var dirt := StandardMaterial3D.new()
	dirt.albedo_color = Color(0.38, 0.3, 0.18)
	dirt.roughness = 0.95
	var path := BoxMesh.new()
	path.size = Vector3(52, 0.08, 4.2)
	var pmi := MeshInstance3D.new()
	pmi.mesh = path
	pmi.material_override = dirt
	pmi.position = Vector3(16, 0.22, 0)
	add_child(pmi)


func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	var n := (b - a).cross(c - a).normalized()
	st.set_normal(n)
	st.add_vertex(a)
	st.add_vertex(b)
	st.add_vertex(c)


func _water() -> void:
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode specular_schlick_ggx, cull_disabled;
uniform vec4 shallow : source_color = vec4(0.18, 0.38, 0.36, 0.82);
uniform vec4 deep : source_color = vec4(0.08, 0.2, 0.24, 0.9);
void vertex() {
	VERTEX.y += sin(TIME * 1.4 + VERTEX.x * 0.35) * 0.04;
}
void fragment() {
	float w = 0.5 + 0.5 * sin(UV.x * 18.0 + TIME * 0.8);
	ALBEDO = mix(deep.rgb, shallow.rgb, w);
	ROUGHNESS = 0.08;
	METALLIC = 0.12;
	ALPHA = 0.84;
	EMISSION = ALBEDO * 0.08;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = sh
	var plane := PlaneMesh.new()
	plane.size = Vector2(18, 12)
	plane.subdivide_width = 24
	plane.subdivide_depth = 16
	var mi := MeshInstance3D.new()
	mi.mesh = plane
	mi.material_override = mat
	mi.position = Vector3(26, -0.35, -9)
	add_child(mi)


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
	add_child(root)
	var bark := StandardMaterial3D.new()
	bark.albedo_color = Color(0.28, 0.18, 0.1).darkened(rng.randf() * 0.15)
	bark.roughness = 0.95
	var leaf := StandardMaterial3D.new()
	leaf.albedo_color = Color(0.16, 0.38, 0.14).lightened(rng.randf() * 0.12)
	leaf.roughness = 0.85
	var trunk := CylinderMesh.new()
	trunk.top_radius = rng.randf_range(0.14, 0.22)
	trunk.bottom_radius = trunk.top_radius + 0.08
	trunk.height = rng.randf_range(3.4, 5.4)
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
	for k in range(3):
		var sph := SphereMesh.new()
		sph.radius = rng.randf_range(1.1, 1.7)
		var smi := MeshInstance3D.new()
		smi.mesh = sph
		smi.material_override = leaf
		smi.position = Vector3(rng.randf_range(-0.5, 0.5), trunk.height + rng.randf_range(-0.2, 0.5), rng.randf_range(-0.5, 0.5))
		root.add_child(smi)


func _rock(pos: Vector3, rng: RandomNumberGenerator) -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.36, 0.33, 0.28)
	mat.roughness = 0.95
	var box := SphereMesh.new()
	box.radius = rng.randf_range(0.4, 1.1)
	var mi := MeshInstance3D.new()
	mi.mesh = box
	mi.material_override = mat
	mi.position = pos + Vector3(0, box.radius * 0.4, 0)
	mi.scale = Vector3(1.0, rng.randf_range(0.45, 0.8), 1.2)
	add_child(mi)


func _grass_field() -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = 220
	var blade := BoxMesh.new()
	blade.size = Vector3(0.08, 0.42, 0.08)
	var gmat := StandardMaterial3D.new()
	gmat.albedo_color = Color(0.22, 0.46, 0.16)
	gmat.roughness = 0.9
	var mi := MultiMeshInstance3D.new()
	mm.mesh = blade
	mi.multimesh = mm
	mi.material_override = gmat
	add_child(mi)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for i in range(mm.instance_count):
		var x := rng.randf_range(-30, 40)
		var z := rng.randf_range(-28, 28)
		var xf := Transform3D.IDENTITY
		xf.origin = Vector3(x, height_at(x, z), z)
		xf.basis = xf.basis.rotated(Vector3.UP, rng.randf() * TAU)
		mm.set_instance_transform(i, xf)


func _camp() -> void:
	var stone := StandardMaterial3D.new()
	stone.albedo_color = Color(0.4, 0.36, 0.3)
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
	fire.light_energy = 1.6
	fire.omni_range = 6.0
	fire.position = Vector3(0, 0.8, 0)
	add_child(fire)
	var tent := BoxMesh.new()
	tent.size = Vector3(2.4, 1.6, 2.2)
	var canvas := StandardMaterial3D.new()
	canvas.albedo_color = Color(0.55, 0.42, 0.22)
	var tmi := MeshInstance3D.new()
	tmi.mesh = tent
	tmi.material_override = canvas
	tmi.position = Vector3(-3.2, 0.95, -2.4)
	add_child(tmi)


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
	var rock := StandardMaterial3D.new()
	rock.albedo_color = Color(0.34, 0.3, 0.24)
	var left := BoxMesh.new()
	left.size = Vector3(2.4, 3.4, 3.1)
	var mi := MeshInstance3D.new()
	mi.mesh = left
	mi.material_override = rock
	mi.position = Vector3(31.5, height_at(31.5, -4.2) + 1.7, -4.2)
	add_child(mi)
	var mi2 := MeshInstance3D.new()
	mi2.mesh = left.duplicate()
	mi2.material_override = rock
	mi2.position = Vector3(31.5, height_at(31.5, -10.2) + 1.7, -10.2)
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
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.18, 0.32, 0.12)
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
