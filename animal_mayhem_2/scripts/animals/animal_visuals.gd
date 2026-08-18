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
	var dark := MaterialLibrary.animal("buffalo_hide.png", Color(0.62, 0.52, 0.42), 0.9)
	var horn := StandardMaterial3D.new()
	horn.albedo_color = Color(0.55, 0.46, 0.34)
	horn.roughness = 0.52
	horn.metallic = 0.0
	var keratin := StandardMaterial3D.new()
	keratin.albedo_color = Color(0.16, 0.12, 0.09)
	keratin.roughness = 0.62
	var eye_w := StandardMaterial3D.new()
	eye_w.albedo_color = Color(0.88, 0.84, 0.74)
	eye_w.roughness = 0.32
	var pupil := StandardMaterial3D.new()
	pupil.albedo_color = Color(0.06, 0.05, 0.04)
	pupil.roughness = 0.22
	_mesh(p, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0.92, -1.05), Vector3(0, 0.96, -0.55), Vector3(0, 1.0, 0.05),
		Vector3(0, 1.02, 0.55), Vector3(0, 1.0, 0.92)
	]), PackedFloat32Array([0.38, 0.48, 0.55, 0.52, 0.36]), 12), hide, Vector3.ZERO, Vector3.ZERO, Vector3.ONE, "Body")
	_mesh(p, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 1.22, -0.35), Vector3(0, 1.48, -0.08), Vector3(0, 1.28, 0.22)
	]), PackedFloat32Array([0.22, 0.34, 0.2]), 10), dark, Vector3.ZERO, Vector3.ZERO, Vector3.ONE, "Hump")
	_mesh(p, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 1.05, 0.85), Vector3(0, 1.12, 1.05), Vector3(0, 1.18, 1.22)
	]), PackedFloat32Array([0.32, 0.26, 0.22]), 10), hide, Vector3.ZERO)
	_mesh(p, OrganicMesh.loft(PackedVector3Array([
		Vector3(-0.22, 0.95, 0.28), Vector3(-0.28, 1.08, 0.42), Vector3(-0.18, 0.98, 0.55)
	]), PackedFloat32Array([0.16, 0.2, 0.12]), 8), dark, Vector3.ZERO)
	_mesh(p, OrganicMesh.loft(PackedVector3Array([
		Vector3(0.22, 0.95, 0.28), Vector3(0.28, 1.08, 0.42), Vector3(0.18, 0.98, 0.55)
	]), PackedFloat32Array([0.16, 0.2, 0.12]), 8), dark, Vector3.ZERO)
	_mesh(p, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0.78, 0.62), Vector3(0, 0.62, 0.78), Vector3(0, 0.72, 0.95)
	]), PackedFloat32Array([0.16, 0.18, 0.1]), 8), dark, Vector3.ZERO)
	var head := _pivot(p, "Head", Vector3(0, 1.2, 1.32))
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0.02, -0.18), Vector3(0, 0.0, 0.05), Vector3(0, -0.06, 0.28), Vector3(0, -0.14, 0.48)
	]), PackedFloat32Array([0.28, 0.32, 0.22, 0.14]), 10), hide, Vector3.ZERO)
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, -0.16, 0.42), Vector3(0, -0.2, 0.58), Vector3(0, -0.18, 0.7)
	]), PackedFloat32Array([0.14, 0.12, 0.09]), 8), dark, Vector3.ZERO)
	_mesh(head, SphereMesh.new(), pupil, Vector3(-0.06, -0.2, 0.74), Vector3.ZERO, Vector3(0.7, 0.45, 0.35))
	_mesh(head, SphereMesh.new(), pupil, Vector3(0.06, -0.2, 0.74), Vector3.ZERO, Vector3(0.7, 0.45, 0.35))
	var ear_l := _pivot(head, "EarL", Vector3(-0.3, 0.14, -0.06))
	var ear_r := _pivot(head, "EarR", Vector3(0.3, 0.14, -0.06))
	var ear_m := OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0, 0), Vector3(-0.02, 0.12, -0.02), Vector3(0, 0.2, -0.01)
	]), PackedFloat32Array([0.07, 0.05, 0.02]), 6)
	_mesh(ear_l, ear_m, dark, Vector3.ZERO, Vector3(0, 0, -18))
	_mesh(ear_r, ear_m, dark, Vector3.ZERO, Vector3(0, 0, 18))
	_mesh(head, OrganicMesh.curve_horn(PackedVector3Array([
		Vector3(-0.18, 0.22, -0.08), Vector3(-0.32, 0.38, -0.04), Vector3(-0.46, 0.48, 0.04), Vector3(-0.52, 0.42, 0.12)
	]), 0.07, 0.018), horn, Vector3.ZERO)
	_mesh(head, OrganicMesh.curve_horn(PackedVector3Array([
		Vector3(0.18, 0.22, -0.08), Vector3(0.32, 0.38, -0.04), Vector3(0.46, 0.48, 0.04), Vector3(0.52, 0.42, 0.12)
	]), 0.07, 0.018), horn, Vector3.ZERO)
	_mesh(head, SphereMesh.new(), eye_w, Vector3(-0.15, 0.05, 0.26), Vector3.ZERO, Vector3(0.7, 0.55, 0.4))
	_mesh(head, SphereMesh.new(), eye_w, Vector3(0.15, 0.05, 0.26), Vector3.ZERO, Vector3(0.7, 0.55, 0.4))
	_mesh(head, SphereMesh.new(), pupil, Vector3(-0.15, 0.05, 0.31), Vector3.ZERO, Vector3(0.32, 0.32, 0.22))
	_mesh(head, SphereMesh.new(), pupil, Vector3(0.15, 0.05, 0.31), Vector3.ZERO, Vector3(0.32, 0.32, 0.22))
	var names := ["LegFL", "LegFR", "LegBL", "LegBR"]
	var xs := [-0.36, 0.36, -0.38, 0.38]
	var zs := [0.58, 0.58, -0.68, -0.68]
	for i in 4:
		var pivot := _pivot(p, names[i], Vector3(xs[i], 0.82, zs[i]))
		var thick := 0.13 if i > 1 else 0.11
		_mesh(pivot, OrganicMesh.loft(PackedVector3Array([
			Vector3(0, 0.02, 0), Vector3(0, -0.22, 0.02), Vector3(0, -0.4, 0.01)
		]), PackedFloat32Array([thick, thick * 0.85, thick * 0.7]), 8), dark, Vector3.ZERO)
		_mesh(pivot, OrganicMesh.loft(PackedVector3Array([
			Vector3(0, -0.4, 0.01), Vector3(0, -0.62, 0.02), Vector3(0, -0.78, 0.03)
		]), PackedFloat32Array([0.075, 0.06, 0.05]), 7), hide, Vector3.ZERO)
		var hoof := SphereMesh.new()
		hoof.radius = 0.08
		_mesh(pivot, hoof, keratin, Vector3(-0.025, -0.84, 0.05), Vector3.ZERO, Vector3(0.65, 0.4, 1.1))
		_mesh(pivot, hoof.duplicate(), keratin, Vector3(0.025, -0.84, 0.05), Vector3.ZERO, Vector3(0.65, 0.4, 1.1))
	var tail := _pivot(p, "Tail", Vector3(0, 1.12, -1.08))
	_mesh(tail, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0, 0), Vector3(0, -0.18, -0.22), Vector3(0, -0.32, -0.42)
	]), PackedFloat32Array([0.05, 0.04, 0.03]), 6), hide, Vector3.ZERO)
	_mesh(tail, SphereMesh.new(), dark, Vector3(0, -0.36, -0.48), Vector3.ZERO, Vector3(1.1, 0.8, 1.1))


static func _monkey(p: Node3D) -> void:
	p.scale = Vector3(1.16, 1.16, 1.16)
	var fur := MaterialLibrary.animal("monkey_fur.png", Color(1, 1, 1), 0.9)
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.74, 0.54, 0.42)
	skin.roughness = 0.7
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.1, 0.07, 0.05)
	dark.roughness = 0.35
	_mesh(p, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0.42, -0.04), Vector3(0, 0.68, 0.02), Vector3(0, 0.92, 0.04)
	]), PackedFloat32Array([0.16, 0.22, 0.17]), 10), fur, Vector3.ZERO, Vector3.ZERO, Vector3.ONE, "Body")
	var head := _pivot(p, "Head", Vector3(0, 1.14, 0.08))
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0.04, -0.08), Vector3(0, 0.02, 0.02), Vector3(0, -0.02, 0.12)
	]), PackedFloat32Array([0.16, 0.19, 0.15]), 10), fur, Vector3.ZERO)
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, -0.02, 0.08), Vector3(0, -0.06, 0.16), Vector3(0, -0.1, 0.22)
	]), PackedFloat32Array([0.12, 0.09, 0.06]), 8), skin, Vector3.ZERO)
	_mesh(head, SphereMesh.new(), fur, Vector3(0, 0.08, 0.1), Vector3.ZERO, Vector3(1.5, 0.4, 0.5))
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0.06, 0.08), Vector3(0, 0.08, 0.14)
	]), PackedFloat32Array([0.12, 0.08]), 6), fur, Vector3.ZERO)
	var ear_m := OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0, 0), Vector3(0, 0.06, 0), Vector3(0, 0.1, 0)
	]), PackedFloat32Array([0.055, 0.04, 0.02]), 6)
	_mesh(_pivot(head, "EarL", Vector3(-0.18, 0.04, -0.02)), ear_m, skin, Vector3.ZERO, Vector3(0, 0, -12))
	_mesh(_pivot(head, "EarR", Vector3(0.18, 0.04, -0.02)), ear_m, skin, Vector3.ZERO, Vector3(0, 0, 12))
	_mesh(head, SphereMesh.new(), dark, Vector3(-0.05, 0.02, 0.18), Vector3.ZERO, Vector3(0.28, 0.34, 0.2))
	_mesh(head, SphereMesh.new(), dark, Vector3(0.05, 0.02, 0.18), Vector3.ZERO, Vector3(0.28, 0.34, 0.2))
	for side in [-1.0, 1.0]:
		var arm := _pivot(p, "ArmL" if side < 0 else "ArmR", Vector3(0.24 * side, 0.88, 0.04))
		_mesh(arm, OrganicMesh.loft(PackedVector3Array([
			Vector3(0.02 * side, 0.02, 0), Vector3(0.05 * side, -0.18, 0.03), Vector3(0.1 * side, -0.38, 0.06)
		]), PackedFloat32Array([0.055, 0.048, 0.04]), 7), fur, Vector3.ZERO)
		_mesh(arm, OrganicMesh.loft(PackedVector3Array([
			Vector3(0.1 * side, -0.38, 0.06), Vector3(0.13 * side, -0.5, 0.1)
		]), PackedFloat32Array([0.04, 0.035]), 6), fur, Vector3.ZERO)
		_mesh(arm, SphereMesh.new(), skin, Vector3(0.14 * side, -0.52, 0.12), Vector3.ZERO, Vector3(0.9, 0.7, 1.0))
		var finger := CapsuleMesh.new()
		finger.radius = 0.011
		finger.height = 0.07
		_mesh(arm, finger, skin, Vector3(0.16 * side, -0.57, 0.16), Vector3(70, 0, 0))
		_mesh(arm, finger.duplicate(), skin, Vector3(0.12 * side, -0.57, 0.17), Vector3(70, 0, 0))
	for side in [-1.0, 1.0]:
		var leg := _pivot(p, "LegL" if side < 0 else "LegR", Vector3(0.1 * side, 0.42, 0.02))
		_mesh(leg, OrganicMesh.loft(PackedVector3Array([
			Vector3(0, 0.02, 0), Vector3(0, -0.18, 0.01), Vector3(0, -0.36, 0.02)
		]), PackedFloat32Array([0.07, 0.06, 0.048]), 7), fur, Vector3.ZERO)
		_mesh(leg, SphereMesh.new(), skin, Vector3(0, -0.5, 0.07), Vector3.ZERO, Vector3(0.85, 0.4, 1.45))
	var tail := _pivot(p, "Tail", Vector3(0.02, 0.68, -0.22))
	_mesh(tail, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0, 0), Vector3(0.06, 0.04, -0.18), Vector3(0.14, 0.1, -0.4), Vector3(0.18, 0.08, -0.58)
	]), PackedFloat32Array([0.038, 0.032, 0.026, 0.018]), 6), fur, Vector3.ZERO)


static func _snake(p: Node3D) -> void:
	p.scale = Vector3(1.1, 1.1, 1.1)
	var scales := MaterialLibrary.animal("snake_scales.png", Color(0.9, 0.96, 0.78), 0.6)
	var belly := MaterialLibrary.animal("snake_scales.png", Color(0.76, 0.68, 0.44), 0.66)
	var segs := Node3D.new()
	segs.name = "Segments"
	p.add_child(segs)
	for i in range(20):
		var n := Node3D.new()
		n.name = "S%d" % i
		n.position = Vector3(0, 0.09, -i * 0.175)
		segs.add_child(n)
	var body := MeshInstance3D.new()
	body.name = "BodyMesh"
	body.material_override = scales
	p.add_child(body)
	var head := _pivot(p, "Head", Vector3(0, 0.12, 0.26))
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, 0.0, -0.08), Vector3(0, 0.01, 0.06), Vector3(0, -0.02, 0.2)
	]), PackedFloat32Array([0.11, 0.13, 0.08]), 10), scales, Vector3.ZERO)
	_mesh(head, OrganicMesh.loft(PackedVector3Array([
		Vector3(0, -0.04, 0.12), Vector3(0, -0.05, 0.22)
	]), PackedFloat32Array([0.07, 0.05]), 8), belly, Vector3.ZERO)
	var gold := StandardMaterial3D.new()
	gold.albedo_color = Color(0.58, 0.48, 0.14)
	gold.roughness = 0.38
	_mesh(head, SphereMesh.new(), gold, Vector3(-0.07, 0.04, 0.12), Vector3.ZERO, Vector3(0.35, 0.3, 0.28))
	_mesh(head, SphereMesh.new(), gold, Vector3(0.07, 0.04, 0.12), Vector3.ZERO, Vector3(0.35, 0.3, 0.28))
	var pupil := StandardMaterial3D.new()
	pupil.albedo_color = Color(0.07, 0.06, 0.04)
	pupil.roughness = 0.25
	_mesh(head, SphereMesh.new(), pupil, Vector3(-0.07, 0.04, 0.15), Vector3.ZERO, Vector3(0.16, 0.2, 0.1))
	_mesh(head, SphereMesh.new(), pupil, Vector3(0.07, 0.04, 0.15), Vector3.ZERO, Vector3(0.16, 0.2, 0.1))
	var tongue := StandardMaterial3D.new()
	tongue.albedo_color = Color(0.58, 0.14, 0.12)
	tongue.roughness = 0.45
	var t := BoxMesh.new()
	t.size = Vector3(0.016, 0.007, 0.14)
	_mesh(head, t, tongue, Vector3(0, -0.03, 0.28), Vector3.ZERO, Vector3.ONE, "Tongue")
	var pts := PackedVector3Array()
	pts.append(Vector3(0, 0.12, 0.26))
	for i in range(20):
		pts.append(Vector3(0, 0.09, -i * 0.175))
	SnakeTube.rebuild(body, pts, scales)
