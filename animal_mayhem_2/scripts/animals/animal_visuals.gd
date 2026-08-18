class_name AnimalVisuals
extends RefCounted
## Semi-realistic assembled animals. Swap this builder for licensed GLTF later.
## No verified CC0 photogrammetry buffalo/monkey/snake GLTF was available.


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
	p.scale = Vector3(1.06, 1.06, 1.06)
	var hide := MaterialLibrary.animal("buffalo_hide.png", Color(1, 1, 1), 0.86)
	var dark := MaterialLibrary.animal("buffalo_hide.png", Color(0.55, 0.48, 0.4), 0.9)
	var horn := StandardMaterial3D.new()
	horn.albedo_color = Color(0.62, 0.52, 0.4)
	horn.roughness = 0.48
	horn.metallic = 0.02
	var keratin := StandardMaterial3D.new()
	keratin.albedo_color = Color(0.18, 0.14, 0.1)
	keratin.roughness = 0.55
	var eye_w := StandardMaterial3D.new()
	eye_w.albedo_color = Color(0.9, 0.86, 0.78)
	eye_w.roughness = 0.28
	var pupil := StandardMaterial3D.new()
	pupil.albedo_color = Color(0.07, 0.06, 0.04)
	pupil.roughness = 0.18
	var body := CapsuleMesh.new()
	body.radius = 0.62
	body.height = 2.15
	_mesh(p, body, hide, Vector3(0, 0.98, 0.02), Vector3(90, 0, 0), Vector3(1.18, 1.05, 1.08), "Body")
	var chest := SphereMesh.new()
	chest.radius = 0.52
	_mesh(p, chest, hide, Vector3(0, 1.02, 0.62), Vector3.ZERO, Vector3(1.15, 0.85, 0.95))
	var hump := SphereMesh.new()
	hump.radius = 0.48
	_mesh(p, hump, dark, Vector3(0, 1.52, -0.08), Vector3.ZERO, Vector3(1.2, 0.78, 0.95), "Hump")
	var neck := CapsuleMesh.new()
	neck.radius = 0.28
	neck.height = 0.72
	_mesh(p, neck, hide, Vector3(0, 1.18, 0.92), Vector3(58, 0, 0), Vector3(1.15, 1, 1.05))
	var dewlap := SphereMesh.new()
	dewlap.radius = 0.22
	_mesh(p, dewlap, dark, Vector3(0, 0.72, 0.78), Vector3.ZERO, Vector3(0.7, 1.15, 1.1))
	var head := _pivot(p, "Head", Vector3(0, 1.22, 1.28))
	var hd := SphereMesh.new()
	hd.radius = 0.38
	_mesh(head, hd, hide, Vector3.ZERO, Vector3.ZERO, Vector3(1.05, 0.88, 1.12))
	var snout := CapsuleMesh.new()
	snout.radius = 0.16
	snout.height = 0.55
	_mesh(head, snout, dark, Vector3(0, -0.16, 0.38), Vector3(72, 0, 0))
	var muzzle := SphereMesh.new()
	muzzle.radius = 0.14
	_mesh(head, muzzle, dark, Vector3(0, -0.22, 0.58), Vector3.ZERO, Vector3(1.15, 0.7, 0.85))
	var nostril := SphereMesh.new()
	nostril.radius = 0.035
	_mesh(head, nostril, pupil, Vector3(-0.07, -0.24, 0.68))
	_mesh(head, nostril.duplicate(), pupil, Vector3(0.07, -0.24, 0.68))
	var ear := SphereMesh.new()
	ear.radius = 0.09
	_mesh(head, ear, dark, Vector3(-0.34, 0.16, -0.08), Vector3.ZERO, Vector3(0.45, 1.25, 0.65))
	_mesh(head, ear.duplicate(), dark, Vector3(0.34, 0.16, -0.08), Vector3.ZERO, Vector3(0.45, 1.25, 0.65))
	var base_h := CapsuleMesh.new()
	base_h.radius = 0.07
	base_h.height = 0.42
	_mesh(head, base_h, horn, Vector3(-0.22, 0.32, -0.08), Vector3(12, 18, 42))
	_mesh(head, base_h.duplicate(), horn, Vector3(0.22, 0.32, -0.08), Vector3(12, -18, -42))
	var tip := CapsuleMesh.new()
	tip.radius = 0.045
	tip.height = 0.55
	_mesh(head, tip, horn, Vector3(-0.42, 0.52, -0.02), Vector3(8, 28, 78))
	_mesh(head, tip.duplicate(), horn, Vector3(0.42, 0.52, -0.02), Vector3(8, -28, -78))
	_mesh(head, SphereMesh.new(), eye_w, Vector3(-0.16, 0.06, 0.28), Vector3.ZERO, Vector3(0.85, 0.7, 0.5))
	_mesh(head, SphereMesh.new(), eye_w, Vector3(0.16, 0.06, 0.28), Vector3.ZERO, Vector3(0.85, 0.7, 0.5))
	_mesh(head, SphereMesh.new(), pupil, Vector3(-0.16, 0.06, 0.34), Vector3.ZERO, Vector3(0.4, 0.4, 0.28))
	_mesh(head, SphereMesh.new(), pupil, Vector3(0.16, 0.06, 0.34), Vector3.ZERO, Vector3(0.4, 0.4, 0.28))
	var names := ["LegFL", "LegFR", "LegBL", "LegBR"]
	var xs := [-0.38, 0.38, -0.4, 0.4]
	var zs := [0.62, 0.62, -0.62, -0.62]
	for i in 4:
		var pivot := _pivot(p, names[i], Vector3(xs[i], 0.78, zs[i]))
		var thigh := CylinderMesh.new()
		thigh.top_radius = 0.14 if i > 1 else 0.12
		thigh.bottom_radius = 0.1
		thigh.height = 0.4
		_mesh(pivot, thigh, dark, Vector3(0, -0.18, 0))
		var shin := CylinderMesh.new()
		shin.top_radius = 0.085
		shin.bottom_radius = 0.07
		shin.height = 0.36
		_mesh(pivot, shin, hide, Vector3(0, -0.52, 0))
		var fetlock := SphereMesh.new()
		fetlock.radius = 0.07
		_mesh(pivot, fetlock, hide, Vector3(0, -0.7, 0.02))
		var hoof := SphereMesh.new()
		hoof.radius = 0.085
		_mesh(pivot, hoof, keratin, Vector3(-0.03, -0.8, 0.04), Vector3.ZERO, Vector3(0.7, 0.45, 1.15))
		_mesh(pivot, hoof.duplicate(), keratin, Vector3(0.03, -0.8, 0.04), Vector3.ZERO, Vector3(0.7, 0.45, 1.15))
	var tail := _pivot(p, "Tail", Vector3(0, 1.15, -1.12))
	var tmesh := CapsuleMesh.new()
	tmesh.radius = 0.05
	tmesh.height = 0.8
	_mesh(tail, tmesh, hide, Vector3(0, -0.12, -0.22), Vector3(48, 0, 0))
	var tuft := SphereMesh.new()
	tuft.radius = 0.11
	_mesh(tail, tuft, dark, Vector3(0, -0.38, -0.48))


static func _monkey(p: Node3D) -> void:
	p.scale = Vector3(1.18, 1.18, 1.18)
	var fur := MaterialLibrary.animal("monkey_fur.png", Color(1, 1, 1), 0.88)
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.76, 0.56, 0.42)
	skin.roughness = 0.68
	skin.metallic = 0.0
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.1, 0.07, 0.05)
	dark.roughness = 0.32
	var torso := CapsuleMesh.new()
	torso.radius = 0.22
	torso.height = 0.72
	_mesh(p, torso, fur, Vector3(0, 0.68, 0.02), Vector3(8, 0, 0), Vector3(1.12, 1.0, 0.88), "Body")
	var belly := SphereMesh.new()
	belly.radius = 0.18
	_mesh(p, belly, fur, Vector3(0, 0.58, 0.08), Vector3.ZERO, Vector3(1.05, 0.9, 0.85))
	var head := _pivot(p, "Head", Vector3(0, 1.18, 0.1))
	var hd := SphereMesh.new()
	hd.radius = 0.2
	_mesh(head, hd, fur, Vector3.ZERO)
	var face := SphereMesh.new()
	face.radius = 0.145
	_mesh(head, face, skin, Vector3(0, -0.03, 0.11), Vector3.ZERO, Vector3(0.92, 0.9, 0.7))
	var muzzle := SphereMesh.new()
	muzzle.radius = 0.075
	_mesh(head, muzzle, skin, Vector3(0, -0.09, 0.2), Vector3.ZERO, Vector3(1.15, 0.68, 0.95))
	var brow := SphereMesh.new()
	brow.radius = 0.06
	_mesh(head, brow, fur, Vector3(0, 0.08, 0.12), Vector3.ZERO, Vector3(1.6, 0.45, 0.5))
	var ear := SphereMesh.new()
	ear.radius = 0.075
	_mesh(head, ear, skin, Vector3(-0.2, 0.04, -0.02), Vector3.ZERO, Vector3(0.55, 1.2, 0.4))
	_mesh(head, ear.duplicate(), skin, Vector3(0.2, 0.04, -0.02), Vector3.ZERO, Vector3(0.55, 1.2, 0.4))
	_mesh(head, SphereMesh.new(), dark, Vector3(-0.055, 0.02, 0.2), Vector3.ZERO, Vector3(0.32, 0.38, 0.22))
	_mesh(head, SphereMesh.new(), dark, Vector3(0.055, 0.02, 0.2), Vector3.ZERO, Vector3(0.32, 0.38, 0.22))
	for side in [-1.0, 1.0]:
		var arm := _pivot(p, "ArmL" if side < 0 else "ArmR", Vector3(0.26 * side, 0.9, 0.04))
		var upper := CapsuleMesh.new()
		upper.radius = 0.055
		upper.height = 0.38
		_mesh(arm, upper, fur, Vector3(0.04 * side, -0.16, 0.02), Vector3(18, 0, 22 * side))
		var lower := CapsuleMesh.new()
		lower.radius = 0.045
		lower.height = 0.32
		_mesh(arm, lower, fur, Vector3(0.1 * side, -0.36, 0.06), Vector3(28, 0, 8 * side))
		var hand := SphereMesh.new()
		hand.radius = 0.048
		_mesh(arm, hand, skin, Vector3(0.14 * side, -0.5, 0.1))
		var finger := CapsuleMesh.new()
		finger.radius = 0.012
		finger.height = 0.08
		_mesh(arm, finger, skin, Vector3(0.16 * side, -0.55, 0.14), Vector3(70, 0, 0))
		_mesh(arm, finger.duplicate(), skin, Vector3(0.12 * side, -0.55, 0.15), Vector3(70, 0, 0))
	for side in [-1.0, 1.0]:
		var leg := _pivot(p, "LegL" if side < 0 else "LegR", Vector3(0.11 * side, 0.4, 0.02))
		var thigh := CapsuleMesh.new()
		thigh.radius = 0.07
		thigh.height = 0.34
		_mesh(leg, thigh, fur, Vector3(0, -0.14, 0))
		var shin := CapsuleMesh.new()
		shin.radius = 0.05
		shin.height = 0.28
		_mesh(leg, shin, fur, Vector3(0, -0.36, 0.02))
		var foot := SphereMesh.new()
		foot.radius = 0.055
		_mesh(leg, foot, skin, Vector3(0, -0.5, 0.06), Vector3.ZERO, Vector3(0.85, 0.42, 1.45))
	var tail := _pivot(p, "Tail", Vector3(0.02, 0.7, -0.26))
	var t1 := CapsuleMesh.new()
	t1.radius = 0.038
	t1.height = 0.42
	_mesh(tail, t1, fur, Vector3(0.04, 0.02, -0.16), Vector3(40, 18, 0))
	var t2 := CapsuleMesh.new()
	t2.radius = 0.03
	t2.height = 0.5
	_mesh(tail, t2, fur, Vector3(0.14, 0.12, -0.42), Vector3(22, 32, 0))


static func _snake(p: Node3D) -> void:
	p.scale = Vector3(1.12, 1.12, 1.12)
	var scales := MaterialLibrary.animal("snake_scales.png", Color(0.92, 0.98, 0.82), 0.58)
	var belly := MaterialLibrary.animal("snake_scales.png", Color(0.78, 0.7, 0.46), 0.64)
	var segs := Node3D.new()
	segs.name = "Segments"
	p.add_child(segs)
	for i in range(16):
		var n := Node3D.new()
		n.name = "S%d" % i
		n.position = Vector3(0, 0.12, -i * 0.2)
		segs.add_child(n)
	var body := MeshInstance3D.new()
	body.name = "BodyMesh"
	body.material_override = scales
	p.add_child(body)
	p.set_meta("belly_mat", belly)
	var head := _pivot(p, "Head", Vector3(0, 0.16, 0.28))
	var hd := SphereMesh.new()
	hd.radius = 0.175
	_mesh(head, hd, scales, Vector3.ZERO, Vector3.ZERO, Vector3(0.78, 0.62, 1.35))
	var jaw := SphereMesh.new()
	jaw.radius = 0.09
	_mesh(head, jaw, belly, Vector3(0, -0.05, 0.14), Vector3.ZERO, Vector3(0.85, 0.5, 1.15))
	var ridge := CapsuleMesh.new()
	ridge.radius = 0.04
	ridge.height = 0.22
	_mesh(head, ridge, scales, Vector3(0, 0.06, 0.02), Vector3(90, 0, 0))
	var gold := StandardMaterial3D.new()
	gold.albedo_color = Color(0.62, 0.52, 0.14)
	gold.roughness = 0.34
	_mesh(head, SphereMesh.new(), gold, Vector3(-0.09, 0.05, 0.14), Vector3.ZERO, Vector3(0.4, 0.35, 0.32))
	_mesh(head, SphereMesh.new(), gold, Vector3(0.09, 0.05, 0.14), Vector3.ZERO, Vector3(0.4, 0.35, 0.32))
	var pupil := StandardMaterial3D.new()
	pupil.albedo_color = Color(0.08, 0.07, 0.04)
	pupil.roughness = 0.22
	_mesh(head, SphereMesh.new(), pupil, Vector3(-0.09, 0.05, 0.17), Vector3.ZERO, Vector3(0.18, 0.22, 0.12))
	_mesh(head, SphereMesh.new(), pupil, Vector3(0.09, 0.05, 0.17), Vector3.ZERO, Vector3(0.18, 0.22, 0.12))
	var tongue := StandardMaterial3D.new()
	tongue.albedo_color = Color(0.62, 0.16, 0.14)
	tongue.roughness = 0.42
	var t := BoxMesh.new()
	t.size = Vector3(0.018, 0.008, 0.15)
	_mesh(head, t, tongue, Vector3(0, -0.02, 0.32), Vector3.ZERO, Vector3.ONE, "Tongue")
