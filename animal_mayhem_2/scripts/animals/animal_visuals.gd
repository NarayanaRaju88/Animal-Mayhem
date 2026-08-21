class_name AnimalVisuals
extends RefCounted
## Semi-realistic lofted animals. Swap this builder for licensed GLTF later.
## Suitable licensed photogrammetry buffalo/monkey/snake GLTF was not available.


static func build(kind: StringName, parent: Node3D) -> void:
	match kind:
		&"buffalo":
			_buffalo(parent)
		&"monkey":
			_monkey(parent)
		&"snake":
			_snake(parent)


static func _mesh(parent: Node3D, mesh: Mesh, mat: Material, pos: Vector3, rot := Vector3.ZERO, scale := Vector3.ONE, node_name := "") -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	if node_name != "":
		mi.name = node_name
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot
	mi.scale = scale
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)
	return mi


static func _pivot(parent: Node3D, node_name: String, pos: Vector3) -> Node3D:
	var n := Node3D.new()
	n.name = node_name
	n.position = pos
	parent.add_child(n)
	return n


static func _color_mat(albedo: Color, rough: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = albedo
	m.roughness = rough
	m.metallic = 0.0
	return m


static func _loft(
		centers: PackedVector3Array,
		radii: PackedFloat32Array,
		radial := 12,
		wide := 1.0,
		tall := 0.86
	) -> ArrayMesh:
	return OrganicMesh.loft(centers, radii, radial, wide, tall)


static func _ground_contact(parent: Node3D, radius: float, along_z := 1.0) -> void:
	var mi := MeshInstance3D.new()
	mi.name = "ContactShadow"
	var disc := CylinderMesh.new()
	disc.top_radius = radius
	disc.bottom_radius = radius * 0.92
	disc.height = 0.014
	mi.mesh = disc
	var m := _color_mat(Color(0.05, 0.04, 0.03, 0.32), 1.0)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	mi.material_override = m
	mi.position = Vector3(0.0, 0.007, 0.02)
	mi.scale = Vector3(1.0, 1.0, along_z)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)


static func _buffalo(p: Node3D) -> void:
	p.scale = Vector3(1.04, 1.04, 1.04)
	var hide := MaterialLibrary.animal("buffalo_hide.png", Color(0.96, 0.93, 0.88), 0.94, 0.035, 0.72)
	var dark := MaterialLibrary.animal("buffalo_hide.png", Color(0.5, 0.42, 0.33), 0.95, 0.03, 0.78)
	var horn := _color_mat(Color(0.46, 0.38, 0.28), 0.62)
	var keratin := _color_mat(Color(0.16, 0.11, 0.08), 0.78)
	var eye_w := _color_mat(Color(0.78, 0.74, 0.64), 0.46)
	var pupil := _color_mat(Color(0.05, 0.04, 0.03), 0.32)
	_ground_contact(p, 0.72, 1.55)
	_mesh(p, _loft(PackedVector3Array([
		Vector3(0, 0.86, -1.14), Vector3(0, 0.9, -0.62), Vector3(0, 0.92, -0.06),
		Vector3(0, 0.98, 0.42), Vector3(0, 0.96, 0.88), Vector3(0, 0.9, 1.14)
	]), PackedFloat32Array([0.32, 0.52, 0.62, 0.56, 0.42, 0.26]), 14, 1.22, 0.74), hide, Vector3.ZERO, Vector3.ZERO, Vector3.ONE, "Body")
	_mesh(p, _loft(PackedVector3Array([
		Vector3(0, 1.02, -0.38), Vector3(0, 1.38, -0.1), Vector3(0, 1.5, 0.1), Vector3(0, 1.18, 0.34)
	]), PackedFloat32Array([0.3, 0.38, 0.32, 0.18]), 12, 1.08, 0.78), dark, Vector3.ZERO, Vector3.ZERO, Vector3.ONE, "Hump")
	_mesh(p, _loft(PackedVector3Array([
		Vector3(0, 0.98, 0.72), Vector3(0, 1.08, 0.98), Vector3(0, 1.14, 1.2)
	]), PackedFloat32Array([0.36, 0.28, 0.18]), 12, 1.1, 0.8), hide, Vector3.ZERO)
	_mesh(p, _loft(PackedVector3Array([
		Vector3(0, 0.78, 0.48), Vector3(0, 0.5, 0.74), Vector3(0, 0.56, 1.0)
	]), PackedFloat32Array([0.2, 0.22, 0.1]), 10, 1.22, 0.68), dark, Vector3.ZERO)
	var head := _pivot(p, "Head", Vector3(0, 1.14, 1.26))
	_mesh(head, _loft(PackedVector3Array([
		Vector3(0, 0.06, -0.24), Vector3(0, 0.04, 0.02), Vector3(0, -0.06, 0.3), Vector3(0, -0.14, 0.48)
	]), PackedFloat32Array([0.32, 0.35, 0.24, 0.14]), 12, 1.14, 0.78), hide, Vector3.ZERO)
	_mesh(head, _loft(PackedVector3Array([
		Vector3(0, -0.12, 0.38), Vector3(0, -0.2, 0.54), Vector3(0, -0.18, 0.68)
	]), PackedFloat32Array([0.14, 0.11, 0.07]), 10, 1.18, 0.7), dark, Vector3.ZERO)
	_mesh(head, _loft(PackedVector3Array([
		Vector3(-0.04, -0.2, 0.66), Vector3(-0.04, -0.18, 0.74)
	]), PackedFloat32Array([0.028, 0.016]), 6, 1.2, 0.7), pupil, Vector3.ZERO)
	_mesh(head, _loft(PackedVector3Array([
		Vector3(0.04, -0.2, 0.66), Vector3(0.04, -0.18, 0.74)
	]), PackedFloat32Array([0.028, 0.016]), 6, 1.2, 0.7), pupil, Vector3.ZERO)
	var ear_l := _pivot(head, "EarL", Vector3(-0.3, 0.12, -0.08))
	var ear_r := _pivot(head, "EarR", Vector3(0.3, 0.12, -0.08))
	var ear_m := _loft(PackedVector3Array([
		Vector3(0, 0, 0), Vector3(-0.01, 0.1, -0.03), Vector3(0, 0.2, -0.02)
	]), PackedFloat32Array([0.07, 0.048, 0.016]), 7, 0.68, 1.18)
	_mesh(ear_l, ear_m, dark, Vector3.ZERO, Vector3(8, 0, -22))
	_mesh(ear_r, ear_m, dark, Vector3.ZERO, Vector3(8, 0, 22))
	_mesh(head, OrganicMesh.curve_horn(PackedVector3Array([
		Vector3(-0.18, 0.16, -0.08), Vector3(-0.32, 0.34, -0.04), Vector3(-0.46, 0.4, 0.04), Vector3(-0.52, 0.3, 0.14)
	]), 0.082, 0.016, 8), horn, Vector3.ZERO)
	_mesh(head, OrganicMesh.curve_horn(PackedVector3Array([
		Vector3(0.18, 0.16, -0.08), Vector3(0.32, 0.34, -0.04), Vector3(0.46, 0.4, 0.04), Vector3(0.52, 0.3, 0.14)
	]), 0.082, 0.016, 8), horn, Vector3.ZERO)
	_mesh(head, _loft(PackedVector3Array([
		Vector3(-0.14, 0.05, 0.2), Vector3(-0.14, 0.05, 0.28)
	]), PackedFloat32Array([0.048, 0.03]), 7, 1.1, 0.7), eye_w, Vector3.ZERO)
	_mesh(head, _loft(PackedVector3Array([
		Vector3(0.14, 0.05, 0.2), Vector3(0.14, 0.05, 0.28)
	]), PackedFloat32Array([0.048, 0.03]), 7, 1.1, 0.7), eye_w, Vector3.ZERO)
	_mesh(head, _loft(PackedVector3Array([
		Vector3(-0.14, 0.05, 0.26), Vector3(-0.14, 0.05, 0.32)
	]), PackedFloat32Array([0.02, 0.012]), 6), pupil, Vector3.ZERO)
	_mesh(head, _loft(PackedVector3Array([
		Vector3(0.14, 0.05, 0.26), Vector3(0.14, 0.05, 0.32)
	]), PackedFloat32Array([0.02, 0.012]), 6), pupil, Vector3.ZERO)
	var names := ["LegFL", "LegFR", "LegBL", "LegBR"]
	var xs := [-0.36, 0.36, -0.38, 0.38]
	var zs := [0.5, 0.5, -0.74, -0.74]
	for i in 4:
		var pivot := _pivot(p, names[i], Vector3(xs[i], 0.86, zs[i]))
		var thick := 0.168 if i > 1 else 0.138
		_mesh(pivot, _loft(PackedVector3Array([
			Vector3(0, 0.06, 0.02), Vector3(0, -0.16, 0.02), Vector3(0, -0.4, 0.01), Vector3(0, -0.58, 0.02),
			Vector3(0, -0.78, 0.03)
		]), PackedFloat32Array([thick, thick * 0.9, thick * 0.58, 0.058, 0.05]), 9, 1.08, 0.88), hide if i > 1 else dark, Vector3.ZERO)
		_mesh(pivot, _loft(PackedVector3Array([
			Vector3(-0.03, -0.8, 0.02), Vector3(-0.032, -0.84, 0.07), Vector3(-0.03, -0.855, 0.11)
		]), PackedFloat32Array([0.046, 0.04, 0.026]), 7, 0.78, 0.42), keratin, Vector3.ZERO)
		_mesh(pivot, _loft(PackedVector3Array([
			Vector3(0.03, -0.8, 0.02), Vector3(0.032, -0.84, 0.07), Vector3(0.03, -0.855, 0.11)
		]), PackedFloat32Array([0.046, 0.04, 0.026]), 7, 0.78, 0.42), keratin, Vector3.ZERO)
	var tail := _pivot(p, "Tail", Vector3(0, 1.06, -1.14))
	_mesh(tail, _loft(PackedVector3Array([
		Vector3(0, 0, 0), Vector3(0, -0.16, -0.2), Vector3(0, -0.3, -0.4), Vector3(0, -0.38, -0.52)
	]), PackedFloat32Array([0.052, 0.036, 0.024, 0.048]), 7, 0.9, 0.85), hide, Vector3.ZERO)


static func _monkey(p: Node3D) -> void:
	p.scale = Vector3(1.12, 1.12, 1.12)
	var fur := MaterialLibrary.animal("monkey_fur.png", Color(0.92, 0.86, 0.78), 0.93, 0.04, 0.68)
	var skin := _color_mat(Color(0.7, 0.5, 0.4), 0.82)
	var dark := _color_mat(Color(0.08, 0.06, 0.04), 0.4)
	_ground_contact(p, 0.28, 0.85)
	_mesh(p, _loft(PackedVector3Array([
		Vector3(0, 0.3, 0.02), Vector3(0, 0.46, 0.0), Vector3(0, 0.66, 0.02),
		Vector3(0, 0.86, 0.04), Vector3(0, 1.02, 0.03), Vector3(0, 1.14, 0.02)
	]), PackedFloat32Array([0.17, 0.15, 0.21, 0.23, 0.18, 0.1]), 14, 1.16, 0.9), fur, Vector3.ZERO, Vector3.ZERO, Vector3.ONE, "Body")
	var head := _pivot(p, "Head", Vector3(0, 1.2, 0.06))
	_mesh(head, _loft(PackedVector3Array([
		Vector3(0, 0.04, -0.12), Vector3(0, 0.08, -0.02), Vector3(0, 0.04, 0.08), Vector3(0, -0.02, 0.12)
	]), PackedFloat32Array([0.16, 0.2, 0.19, 0.14]), 14, 1.12, 0.92), fur, Vector3.ZERO)
	_mesh(head, _loft(PackedVector3Array([
		Vector3(0, 0.12, -0.02), Vector3(0, 0.16, 0.06), Vector3(0, 0.1, 0.12)
	]), PackedFloat32Array([0.13, 0.11, 0.07]), 10, 1.28, 0.55), fur, Vector3.ZERO)
	_mesh(head, _loft(PackedVector3Array([
		Vector3(0, -0.02, 0.08), Vector3(0, -0.05, 0.16), Vector3(0, -0.07, 0.22), Vector3(0, -0.06, 0.26)
	]), PackedFloat32Array([0.12, 0.09, 0.055, 0.032]), 12, 1.18, 0.72), skin, Vector3.ZERO)
	_mesh(head, _loft(PackedVector3Array([
		Vector3(0, -0.05, 0.24), Vector3(0, -0.04, 0.28)
	]), PackedFloat32Array([0.02, 0.012]), 6, 1.1, 0.7), _color_mat(Color(0.45, 0.28, 0.24), 0.7), Vector3.ZERO)
	var ear_m := _loft(PackedVector3Array([
		Vector3(0, 0, 0), Vector3(0, 0.06, 0.01), Vector3(0, 0.11, 0)
	]), PackedFloat32Array([0.058, 0.048, 0.018]), 8, 0.5, 1.25)
	_mesh(_pivot(head, "EarL", Vector3(-0.2, 0.04, -0.02)), ear_m, skin, Vector3.ZERO, Vector3(6, 12, -18))
	_mesh(_pivot(head, "EarR", Vector3(0.2, 0.04, -0.02)), ear_m, skin, Vector3.ZERO, Vector3(6, -12, 18))
	_mesh(head, _loft(PackedVector3Array([
		Vector3(-0.055, 0.03, 0.14), Vector3(-0.055, 0.03, 0.185)
	]), PackedFloat32Array([0.024, 0.015]), 6, 1.05, 0.72), dark, Vector3.ZERO)
	_mesh(head, _loft(PackedVector3Array([
		Vector3(0.055, 0.03, 0.14), Vector3(0.055, 0.03, 0.185)
	]), PackedFloat32Array([0.024, 0.015]), 6, 1.05, 0.72), dark, Vector3.ZERO)
	for side in [-1.0, 1.0]:
		var arm := _pivot(p, "ArmL" if side < 0 else "ArmR", Vector3(0.2 * side, 0.94, 0.04))
		_mesh(arm, _loft(PackedVector3Array([
			Vector3(0.02 * side, 0.05, 0), Vector3(0.06 * side, -0.12, 0.02), Vector3(0.08 * side, -0.3, 0.05),
			Vector3(0.1 * side, -0.46, 0.09), Vector3(0.12 * side, -0.58, 0.14)
		]), PackedFloat32Array([0.07, 0.06, 0.05, 0.044, 0.048]), 10, 1.08, 0.9), fur, Vector3.ZERO)
		_mesh(arm, _loft(PackedVector3Array([
			Vector3(0.12 * side, -0.58, 0.14), Vector3(0.13 * side, -0.6, 0.2), Vector3(0.13 * side, -0.6, 0.26)
		]), PackedFloat32Array([0.04, 0.036, 0.03]), 8, 0.95, 0.55), skin, Vector3.ZERO)
		_mesh(arm, _loft(PackedVector3Array([
			Vector3(0.11 * side, -0.6, 0.24), Vector3(0.11 * side, -0.61, 0.32)
		]), PackedFloat32Array([0.012, 0.008]), 5, 0.8, 0.7), skin, Vector3.ZERO)
		_mesh(arm, _loft(PackedVector3Array([
			Vector3(0.14 * side, -0.6, 0.24), Vector3(0.15 * side, -0.61, 0.31)
		]), PackedFloat32Array([0.011, 0.007]), 5, 0.8, 0.7), skin, Vector3.ZERO)
		_mesh(arm, _loft(PackedVector3Array([
			Vector3(0.16 * side, -0.59, 0.22), Vector3(0.17 * side, -0.6, 0.28)
		]), PackedFloat32Array([0.01, 0.007]), 5, 0.8, 0.7), skin, Vector3.ZERO)
	for side in [-1.0, 1.0]:
		var leg := _pivot(p, "LegL" if side < 0 else "LegR", Vector3(0.09 * side, 0.34, 0.02))
		_mesh(leg, _loft(PackedVector3Array([
			Vector3(0, 0.06, 0), Vector3(0, -0.1, 0.01), Vector3(0, -0.22, 0.02), Vector3(0, -0.32, 0.05)
		]), PackedFloat32Array([0.08, 0.07, 0.055, 0.05]), 10, 1.1, 0.86), fur, Vector3.ZERO)
		_mesh(leg, _loft(PackedVector3Array([
			Vector3(0, -0.32, 0.04), Vector3(0, -0.335, 0.12), Vector3(0, -0.33, 0.2)
		]), PackedFloat32Array([0.042, 0.038, 0.03]), 8, 0.9, 0.48), skin, Vector3.ZERO)
		_mesh(leg, _loft(PackedVector3Array([
			Vector3(-0.012, -0.33, 0.18), Vector3(-0.012, -0.332, 0.24)
		]), PackedFloat32Array([0.01, 0.007]), 5, 0.8, 0.6), skin, Vector3.ZERO)
		_mesh(leg, _loft(PackedVector3Array([
			Vector3(0.012, -0.33, 0.18), Vector3(0.012, -0.332, 0.24)
		]), PackedFloat32Array([0.01, 0.007]), 5, 0.8, 0.6), skin, Vector3.ZERO)
	var tail := _pivot(p, "Tail", Vector3(0.02, 0.42, -0.16))
	_mesh(tail, _loft(PackedVector3Array([
		Vector3(0, 0, 0), Vector3(0.04, 0.04, -0.14), Vector3(0.1, 0.1, -0.32),
		Vector3(0.16, 0.08, -0.5), Vector3(0.18, 0.0, -0.66)
	]), PackedFloat32Array([0.042, 0.034, 0.026, 0.018, 0.01]), 8, 0.95, 0.9), fur, Vector3.ZERO)


static func _snake(p: Node3D) -> void:
	p.scale = Vector3(1.1, 1.1, 1.1)
	var scales := MaterialLibrary.animal("snake_scales.png", Color(0.72, 0.82, 0.58), 0.7, 0.05, 0.85)
	var belly := MaterialLibrary.animal("snake_scales.png", Color(0.78, 0.7, 0.48), 0.74, 0.03, 0.6)
	_ground_contact(p, 0.22, 3.4)
	var segs := Node3D.new()
	segs.name = "Segments"
	p.add_child(segs)
	for i in range(20):
		var n := Node3D.new()
		n.name = "S%d" % i
		n.position = Vector3(0, 0.055, -i * 0.175)
		segs.add_child(n)
	var body := MeshInstance3D.new()
	body.name = "BodyMesh"
	body.material_override = scales
	p.add_child(body)
	var head := _pivot(p, "Head", Vector3(0, 0.1, 0.26))
	_mesh(head, _loft(PackedVector3Array([
		Vector3(0, 0.01, -0.14), Vector3(0, 0.02, -0.02), Vector3(0, 0.01, 0.1), Vector3(0, -0.02, 0.2),
		Vector3(0, -0.04, 0.28)
	]), PackedFloat32Array([0.12, 0.13, 0.11, 0.07, 0.04]), 12, 1.18, 0.68), scales, Vector3.ZERO)
	_mesh(head, _loft(PackedVector3Array([
		Vector3(0, -0.03, 0.04), Vector3(0, -0.05, 0.16), Vector3(0, -0.045, 0.26)
	]), PackedFloat32Array([0.08, 0.055, 0.028]), 10, 1.22, 0.48), belly, Vector3.ZERO)
	var gold := _color_mat(Color(0.5, 0.42, 0.12), 0.45)
	_mesh(head, _loft(PackedVector3Array([
		Vector3(-0.075, 0.04, 0.08), Vector3(-0.075, 0.04, 0.13)
	]), PackedFloat32Array([0.03, 0.02]), 7, 1.1, 0.7), gold, Vector3.ZERO)
	_mesh(head, _loft(PackedVector3Array([
		Vector3(0.075, 0.04, 0.08), Vector3(0.075, 0.04, 0.13)
	]), PackedFloat32Array([0.03, 0.02]), 7, 1.1, 0.7), gold, Vector3.ZERO)
	var pupil := _color_mat(Color(0.06, 0.05, 0.03), 0.3)
	_mesh(head, _loft(PackedVector3Array([
		Vector3(-0.075, 0.04, 0.12), Vector3(-0.075, 0.04, 0.15)
	]), PackedFloat32Array([0.012, 0.008]), 6, 0.55, 1.25), pupil, Vector3.ZERO)
	_mesh(head, _loft(PackedVector3Array([
		Vector3(0.075, 0.04, 0.12), Vector3(0.075, 0.04, 0.15)
	]), PackedFloat32Array([0.012, 0.008]), 6, 0.55, 1.25), pupil, Vector3.ZERO)
	var tongue := _color_mat(Color(0.56, 0.14, 0.12), 0.48)
	var t := BoxMesh.new()
	t.size = Vector3(0.012, 0.005, 0.1)
	_mesh(head, t, tongue, Vector3(-0.008, -0.04, 0.3), Vector3(0, -8, 0), Vector3.ONE, "Tongue")
	_mesh(head, t.duplicate(), tongue, Vector3(0.008, -0.04, 0.3), Vector3(0, 8, 0))
	var pts := PackedVector3Array()
	pts.append(Vector3(0, 0.1, 0.26))
	for i in range(20):
		pts.append(Vector3(0, 0.055, -i * 0.175))
	SnakeTube.rebuild(body, pts, scales)
