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


static func _buffalo(p: Node3D) -> void:
	p.scale = Vector3(1.04, 1.04, 1.04)
	var hide := MaterialLibrary.animal("buffalo_hide.png", Color(1, 1, 1), 0.88)
	var dark := MaterialLibrary.animal("buffalo_hide.png", Color(0.55, 0.46, 0.36), 0.92)
	var horn := StandardMaterial3D.new()
	horn.albedo_color = Color(0.48, 0.4, 0.3)
	horn.roughness = 0.55
	horn.metallic = 0.0
	var keratin := StandardMaterial3D.new()
	keratin.albedo_color = Color(0.14, 0.1, 0.07)
	keratin.roughness = 0.68
	var eye_w := StandardMaterial3D.new()
	eye_w.albedo_color = Color(0.82, 0.78, 0.68)
	eye_w.roughness = 0.38
	var pupil := StandardMaterial3D.new()
	pupil.albedo_color = Color(0.05, 0.04, 0.03)
	pupil.roughness = 0.25
	_mesh(p, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0.88, -1.12), Vector3(0, 0.94, -0.62), Vector3(0, 1.02, -0.08),
		Vector3(0, 1.04, 0.42), Vector3(0, 1.0, 0.88), Vector3(0, 0.94, 1.12)
	]), PackedFloat32Array([0.34, 0.5, 0.58, 0.54, 0.4, 0.28]), 14, 1.18, 0.78), hide, Vector3.ZERO, Vector3.ZERO, Vector3.ONE, "Body")
	_mesh(p, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 1.08, -0.42), Vector3(0, 1.42, -0.12), Vector3(0, 1.52, 0.08), Vector3(0, 1.22, 0.32)
	]), PackedFloat32Array([0.26, 0.36, 0.32, 0.2]), 12, 1.05, 0.8), dark, Vector3.ZERO, Vector3.ZERO, Vector3.ONE, "Hump")
	_mesh(p, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 1.02, 0.78), Vector3(0, 1.1, 1.02), Vector3(0, 1.16, 1.22)
	]), PackedFloat32Array([0.34, 0.26, 0.2]), 12, 1.08, 0.82), hide, Vector3.ZERO)
	_mesh(p, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0.72, 0.55), Vector3(0, 0.52, 0.78), Vector3(0, 0.62, 1.02)
	]), PackedFloat32Array([0.18, 0.2, 0.1]), 10, 1.2, 0.7), dark, Vector3.ZERO)
	var head := _pivot(p, "Head", Vector3(0, 1.16, 1.28))
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0.04, -0.22), Vector3(0, 0.02, 0.04), Vector3(0, -0.08, 0.32), Vector3(0, -0.16, 0.52)
	]), PackedFloat32Array([0.3, 0.34, 0.22, 0.13]), 12, 1.12, 0.8), hide, Vector3.ZERO)
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, -0.16, 0.42), Vector3(0, -0.22, 0.58), Vector3(0, -0.2, 0.72)
	]), PackedFloat32Array([0.13, 0.11, 0.075]), 10, 1.15, 0.72), dark, Vector3.ZERO)
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(-0.04, -0.22, 0.7), Vector3(-0.04, -0.2, 0.78)
	]), PackedFloat32Array([0.03, 0.018]), 6, 1.2, 0.7), pupil, Vector3.ZERO)
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(0.04, -0.22, 0.7), Vector3(0.04, -0.2, 0.78)
	]), PackedFloat32Array([0.03, 0.018]), 6, 1.2, 0.7), pupil, Vector3.ZERO)
	var ear_l := _pivot(head, "EarL", Vector3(-0.28, 0.12, -0.08))
	var ear_r := _pivot(head, "EarR", Vector3(0.28, 0.12, -0.08))
	var ear_m := OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0, 0), Vector3(-0.01, 0.1, -0.03), Vector3(0, 0.18, -0.02)
	]), PackedFloat32Array([0.065, 0.045, 0.016]), 7, 0.7, 1.15)
	_mesh(ear_l, ear_m, dark, Vector3.ZERO, Vector3(8, 0, -22))
	_mesh(ear_r, ear_m, dark, Vector3.ZERO, Vector3(8, 0, 22))
	_mesh(head, OrganicMesh.curve_horn(PackedVector3Array([
		Vector3(-0.16, 0.18, -0.1), Vector3(-0.3, 0.34, -0.06), Vector3(-0.44, 0.42, 0.02), Vector3(-0.5, 0.34, 0.12)
	]), 0.068, 0.014, 8), horn, Vector3.ZERO)
	_mesh(head, OrganicMesh.curve_horn(PackedVector3Array([
		Vector3(0.16, 0.18, -0.1), Vector3(0.3, 0.34, -0.06), Vector3(0.44, 0.42, 0.02), Vector3(0.5, 0.34, 0.12)
	]), 0.068, 0.014, 8), horn, Vector3.ZERO)
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(-0.14, 0.04, 0.22), Vector3(-0.14, 0.04, 0.3)
	]), PackedFloat32Array([0.045, 0.032]), 7, 1.1, 0.7), eye_w, Vector3.ZERO)
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(0.14, 0.04, 0.22), Vector3(0.14, 0.04, 0.3)
	]), PackedFloat32Array([0.045, 0.032]), 7, 1.1, 0.7), eye_w, Vector3.ZERO)
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(-0.14, 0.04, 0.28), Vector3(-0.14, 0.04, 0.34)
	]), PackedFloat32Array([0.022, 0.014]), 6), pupil, Vector3.ZERO)
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(0.14, 0.04, 0.28), Vector3(0.14, 0.04, 0.34)
	]), PackedFloat32Array([0.022, 0.014]), 6), pupil, Vector3.ZERO)
	var names := ["LegFL", "LegFR", "LegBL", "LegBR"]
	var xs := [-0.34, 0.34, -0.36, 0.36]
	var zs := [0.52, 0.52, -0.72, -0.72]
	for i in 4:
		var pivot := _pivot(p, names[i], Vector3(xs[i], 0.84, zs[i]))
		var thick := 0.125 if i > 1 else 0.105
		_mesh(pivot, OrganicMesh.loft(PackedVector3Array([
			Vector3(0, 0.04, 0.02), Vector3(0, -0.2, 0.02), Vector3(0, -0.42, 0.01), Vector3(0, -0.58, 0.02),
			Vector3(0, -0.76, 0.03)
		]), PackedFloat32Array([thick, thick * 0.88, thick * 0.62, 0.055, 0.048]), 9, 1.05, 0.9), hide if i > 1 else dark, Vector3.ZERO)
		_mesh(pivot, OrganicMesh.loft(PackedVector3Array([
			Vector3(-0.028, -0.78, 0.02), Vector3(-0.03, -0.84, 0.06), Vector3(-0.028, -0.86, 0.1)
		]), PackedFloat32Array([0.042, 0.038, 0.028]), 7, 0.7, 0.55), keratin, Vector3.ZERO)
		_mesh(pivot, OrganicMesh.loft(PackedVector3Array([
			Vector3(0.028, -0.78, 0.02), Vector3(0.03, -0.84, 0.06), Vector3(0.028, -0.86, 0.1)
		]), PackedFloat32Array([0.042, 0.038, 0.028]), 7, 0.7, 0.55), keratin, Vector3.ZERO)
	var tail := _pivot(p, "Tail", Vector3(0, 1.08, -1.12))
	_mesh(tail, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0, 0), Vector3(0, -0.16, -0.2), Vector3(0, -0.3, -0.4), Vector3(0, -0.38, -0.52)
	]), PackedFloat32Array([0.048, 0.036, 0.026, 0.05]), 7, 0.9, 0.85), hide, Vector3.ZERO)


static func _monkey(p: Node3D) -> void:
	p.scale = Vector3(1.16, 1.16, 1.16)
	var fur := MaterialLibrary.animal("monkey_fur.png", Color(1, 1, 1), 0.9)
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.72, 0.52, 0.4)
	skin.roughness = 0.72
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.08, 0.06, 0.04)
	dark.roughness = 0.38
	_mesh(p, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0.38, -0.06), Vector3(0, 0.55, 0.0), Vector3(0, 0.78, 0.03), Vector3(0, 0.98, 0.04)
	]), PackedFloat32Array([0.14, 0.2, 0.2, 0.15]), 12, 1.12, 0.88), fur, Vector3.ZERO, Vector3.ZERO, Vector3.ONE, "Body")
	var head := _pivot(p, "Head", Vector3(0, 1.12, 0.08))
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0.06, -0.1), Vector3(0, 0.04, 0.0), Vector3(0, 0.0, 0.1), Vector3(0, -0.04, 0.16)
	]), PackedFloat32Array([0.15, 0.18, 0.16, 0.12]), 12, 1.08, 0.9), fur, Vector3.ZERO)
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, -0.02, 0.08), Vector3(0, -0.07, 0.16), Vector3(0, -0.11, 0.24)
	]), PackedFloat32Array([0.11, 0.08, 0.05]), 10, 1.15, 0.75), skin, Vector3.ZERO)
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0.1, -0.02), Vector3(0, 0.14, 0.08), Vector3(0, 0.1, 0.14)
	]), PackedFloat32Array([0.12, 0.1, 0.06]), 8, 1.3, 0.55), fur, Vector3.ZERO)
	var ear_m := OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0, 0), Vector3(0, 0.05, 0.01), Vector3(0, 0.09, 0)
	]), PackedFloat32Array([0.05, 0.038, 0.016]), 7, 0.55, 1.2)
	_mesh(_pivot(head, "EarL", Vector3(-0.17, 0.03, -0.02)), ear_m, skin, Vector3.ZERO, Vector3(0, 0, -14))
	_mesh(_pivot(head, "EarR", Vector3(0.17, 0.03, -0.02)), ear_m, skin, Vector3.ZERO, Vector3(0, 0, 14))
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(-0.05, 0.02, 0.16), Vector3(-0.05, 0.02, 0.2)
	]), PackedFloat32Array([0.022, 0.014]), 6, 1.0, 0.75), dark, Vector3.ZERO)
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(0.05, 0.02, 0.16), Vector3(0.05, 0.02, 0.2)
	]), PackedFloat32Array([0.022, 0.014]), 6, 1.0, 0.75), dark, Vector3.ZERO)
	for side in [-1.0, 1.0]:
		var arm := _pivot(p, "ArmL" if side < 0 else "ArmR", Vector3(0.22 * side, 0.9, 0.03))
		_mesh(arm, OrganicMesh.loft(PackedVector3Array([
			Vector3(0.02 * side, 0.04, 0), Vector3(0.05 * side, -0.16, 0.03), Vector3(0.09 * side, -0.36, 0.06),
			Vector3(0.12 * side, -0.5, 0.1), Vector3(0.14 * side, -0.56, 0.14)
		]), PackedFloat32Array([0.052, 0.046, 0.04, 0.036, 0.042]), 8, 1.05, 0.88), fur, Vector3.ZERO)
		_mesh(arm, OrganicMesh.loft(PackedVector3Array([
			Vector3(0.15 * side, -0.57, 0.14), Vector3(0.17 * side, -0.6, 0.2)
		]), PackedFloat32Array([0.018, 0.01]), 5, 0.8, 0.7), skin, Vector3.ZERO)
		_mesh(arm, OrganicMesh.loft(PackedVector3Array([
			Vector3(0.12 * side, -0.57, 0.15), Vector3(0.13 * side, -0.6, 0.21)
		]), PackedFloat32Array([0.016, 0.009]), 5, 0.8, 0.7), skin, Vector3.ZERO)
	for side in [-1.0, 1.0]:
		var leg := _pivot(p, "LegL" if side < 0 else "LegR", Vector3(0.1 * side, 0.42, 0.02))
		_mesh(leg, OrganicMesh.loft(PackedVector3Array([
			Vector3(0, 0.04, 0), Vector3(0, -0.16, 0.01), Vector3(0, -0.34, 0.02), Vector3(0, -0.48, 0.06)
		]), PackedFloat32Array([0.068, 0.058, 0.046, 0.05]), 8, 1.08, 0.85), fur, Vector3.ZERO)
		_mesh(leg, OrganicMesh.loft(PackedVector3Array([
			Vector3(0, -0.48, 0.04), Vector3(0, -0.5, 0.12), Vector3(0, -0.5, 0.16)
		]), PackedFloat32Array([0.04, 0.036, 0.028]), 7, 0.85, 0.5), skin, Vector3.ZERO)
	var tail := _pivot(p, "Tail", Vector3(0.02, 0.66, -0.2))
	_mesh(tail, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0, 0), Vector3(0.05, 0.05, -0.16), Vector3(0.12, 0.12, -0.36), Vector3(0.16, 0.08, -0.54)
	]), PackedFloat32Array([0.036, 0.03, 0.024, 0.014]), 7, 0.95, 0.9), fur, Vector3.ZERO)


static func _snake(p: Node3D) -> void:
	p.scale = Vector3(1.1, 1.1, 1.1)
	var scales := MaterialLibrary.animal("snake_scales.png", Color(0.86, 0.92, 0.72), 0.62)
	var belly := MaterialLibrary.animal("snake_scales.png", Color(0.78, 0.7, 0.46), 0.7)
	var segs := Node3D.new()
	segs.name = "Segments"
	p.add_child(segs)
	for i in range(20):
		var n := Node3D.new()
		n.name = "S%d" % i
		n.position = Vector3(0, 0.08, -i * 0.175)
		segs.add_child(n)
	var body := MeshInstance3D.new()
	body.name = "BodyMesh"
	body.material_override = scales
	p.add_child(body)
	var head := _pivot(p, "Head", Vector3(0, 0.11, 0.26))
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0.01, -0.1), Vector3(0, 0.02, 0.02), Vector3(0, 0.0, 0.12), Vector3(0, -0.03, 0.22)
	]), PackedFloat32Array([0.1, 0.125, 0.1, 0.055]), 12, 1.15, 0.72), scales, Vector3.ZERO)
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, -0.04, 0.08), Vector3(0, -0.055, 0.18), Vector3(0, -0.05, 0.24)
	]), PackedFloat32Array([0.07, 0.05, 0.03]), 10, 1.2, 0.5), belly, Vector3.ZERO)
	var gold := StandardMaterial3D.new()
	gold.albedo_color = Color(0.55, 0.46, 0.12)
	gold.roughness = 0.4
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(-0.07, 0.035, 0.1), Vector3(-0.07, 0.035, 0.14)
	]), PackedFloat32Array([0.028, 0.02]), 7, 1.1, 0.7), gold, Vector3.ZERO)
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(0.07, 0.035, 0.1), Vector3(0.07, 0.035, 0.14)
	]), PackedFloat32Array([0.028, 0.02]), 7, 1.1, 0.7), gold, Vector3.ZERO)
	var pupil := StandardMaterial3D.new()
	pupil.albedo_color = Color(0.06, 0.05, 0.03)
	pupil.roughness = 0.28
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(-0.07, 0.035, 0.13), Vector3(-0.07, 0.035, 0.155)
	]), PackedFloat32Array([0.012, 0.008]), 6, 0.6, 1.2), pupil, Vector3.ZERO)
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(0.07, 0.035, 0.13), Vector3(0.07, 0.035, 0.155)
	]), PackedFloat32Array([0.012, 0.008]), 6, 0.6, 1.2), pupil, Vector3.ZERO)
	var tongue := StandardMaterial3D.new()
	tongue.albedo_color = Color(0.56, 0.14, 0.12)
	tongue.roughness = 0.48
	var t := BoxMesh.new()
	t.size = Vector3(0.012, 0.005, 0.1)
	_mesh(head, t, tongue, Vector3(-0.008, -0.035, 0.28), Vector3(0, -8, 0), Vector3.ONE, "Tongue")
	_mesh(head, t.duplicate(), tongue, Vector3(0.008, -0.035, 0.28), Vector3(0, 8, 0))
	var pts := PackedVector3Array()
	pts.append(Vector3(0, 0.11, 0.26))
	for i in range(20):
		pts.append(Vector3(0, 0.08, -i * 0.175))
	SnakeTube.rebuild(body, pts, scales)
