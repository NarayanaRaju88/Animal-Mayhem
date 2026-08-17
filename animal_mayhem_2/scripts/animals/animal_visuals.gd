class_name AnimalVisuals
extends RefCounted
## Semi-realistic assembled animals with project-owned hide/fur/scale maps.
## Swap this builder for licensed GLTF later without changing gameplay.


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
	p.scale = Vector3(1.18, 1.18, 1.18)
	var hide := MaterialLibrary.animal("buffalo_hide.png", Color(0.92, 0.88, 0.82), 0.82)
	var dark := MaterialLibrary.animal("buffalo_hide.png", Color(0.45, 0.38, 0.32), 0.88)
	var horn := StandardMaterial3D.new()
	horn.albedo_color = Color(0.78, 0.7, 0.55)
	horn.roughness = 0.42
	var eye_w := StandardMaterial3D.new()
	eye_w.albedo_color = Color(0.93, 0.9, 0.82)
	eye_w.roughness = 0.35
	var pupil := StandardMaterial3D.new()
	pupil.albedo_color = Color(0.08, 0.07, 0.05)
	pupil.roughness = 0.2
	var body := CapsuleMesh.new()
	body.radius = 0.68
	body.height = 2.35
	_mesh(p, body, hide, Vector3(0, 0.92, 0.08), Vector3(90, 0, 0), Vector3(1.08, 1.0, 1.05), "Body")
	var hump := SphereMesh.new()
	hump.radius = 0.46
	_mesh(p, hump, dark, Vector3(0, 1.42, -0.12), Vector3.ZERO, Vector3(1.25, 0.72, 0.95), "Hump")
	var head := _pivot(p, "Head", Vector3(0, 1.18, 1.12))
	var hd := SphereMesh.new()
	hd.radius = 0.44
	_mesh(head, hd, hide, Vector3.ZERO, Vector3.ZERO, Vector3(1.08, 0.92, 1.18))
	var snout := CapsuleMesh.new()
	snout.radius = 0.2
	snout.height = 0.62
	_mesh(head, snout, dark, Vector3(0, -0.18, 0.42), Vector3(78, 0, 0))
	var nostril := SphereMesh.new()
	nostril.radius = 0.045
	_mesh(head, nostril, pupil, Vector3(-0.08, -0.22, 0.68))
	_mesh(head, nostril.duplicate(), pupil, Vector3(0.08, -0.22, 0.68))
	var ear := SphereMesh.new()
	ear.radius = 0.1
	_mesh(head, ear, dark, Vector3(-0.38, 0.18, -0.05), Vector3.ZERO, Vector3(0.55, 1.1, 0.7))
	_mesh(head, ear.duplicate(), dark, Vector3(0.38, 0.18, -0.05), Vector3.ZERO, Vector3(0.55, 1.1, 0.7))
	var hmesh := CapsuleMesh.new()
	hmesh.radius = 0.075
	hmesh.height = 0.95
	_mesh(head, hmesh, horn, Vector3(-0.3, 0.38, -0.12), Vector3(18, 12, 58))
	_mesh(head, hmesh.duplicate(), horn, Vector3(0.3, 0.38, -0.12), Vector3(18, -12, -58))
	_mesh(head, SphereMesh.new(), eye_w, Vector3(-0.18, 0.08, 0.32), Vector3.ZERO, Vector3(0.9, 0.8, 0.6))
	_mesh(head, SphereMesh.new(), eye_w, Vector3(0.18, 0.08, 0.32), Vector3.ZERO, Vector3(0.9, 0.8, 0.6))
	_mesh(head, SphereMesh.new(), pupil, Vector3(-0.18, 0.08, 0.38), Vector3.ZERO, Vector3(0.45, 0.45, 0.35))
	_mesh(head, SphereMesh.new(), pupil, Vector3(0.18, 0.08, 0.38), Vector3.ZERO, Vector3(0.45, 0.45, 0.35))
	var names := ["LegFL", "LegFR", "LegBL", "LegBR"]
	var xs := [-0.4, 0.4, -0.4, 0.4]
	var zs := [0.58, 0.58, -0.58, -0.58]
	for i in 4:
		var pivot := _pivot(p, names[i], Vector3(xs[i], 0.72, zs[i]))
		var thigh := CylinderMesh.new()
		thigh.top_radius = 0.13
		thigh.bottom_radius = 0.11
		thigh.height = 0.42
		_mesh(pivot, thigh, dark, Vector3(0, -0.2, 0))
		var shin := CylinderMesh.new()
		shin.top_radius = 0.09
		shin.bottom_radius = 0.08
		shin.height = 0.38
		_mesh(pivot, shin, hide, Vector3(0, -0.55, 0))
		var hoof := SphereMesh.new()
		hoof.radius = 0.09
		_mesh(pivot, hoof, pupil, Vector3(0, -0.76, 0.02), Vector3.ZERO, Vector3(1.1, 0.55, 1.3))
	var tail := CapsuleMesh.new()
	tail.radius = 0.055
	tail.height = 0.85
	_mesh(p, tail, hide, Vector3(0, 1.12, -1.18), Vector3(40, 0, 0), Vector3.ONE, "Tail")
	var tuft := SphereMesh.new()
	tuft.radius = 0.12
	_mesh(p, tuft, dark, Vector3(0, 0.78, -1.48))


static func _monkey(p: Node3D) -> void:
	p.scale = Vector3(1.42, 1.42, 1.42)
	var fur := MaterialLibrary.animal("monkey_fur.png", Color(1, 1, 1), 0.86)
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.78, 0.58, 0.42)
	skin.roughness = 0.62
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.12, 0.08, 0.05)
	dark.roughness = 0.35
	var torso := CapsuleMesh.new()
	torso.radius = 0.24
	torso.height = 0.78
	_mesh(p, torso, fur, Vector3(0, 0.7, 0), Vector3.ZERO, Vector3(1.05, 1.0, 0.9), "Body")
	var head := _pivot(p, "Head", Vector3(0, 1.22, 0.08))
	var hd := SphereMesh.new()
	hd.radius = 0.22
	_mesh(head, hd, fur, Vector3.ZERO)
	var face := SphereMesh.new()
	face.radius = 0.15
	_mesh(head, face, skin, Vector3(0, -0.04, 0.12), Vector3.ZERO, Vector3(0.95, 0.88, 0.72))
	var muzzle := SphereMesh.new()
	muzzle.radius = 0.08
	_mesh(head, muzzle, skin, Vector3(0, -0.1, 0.2), Vector3.ZERO, Vector3(1.1, 0.7, 0.9))
	var ear := SphereMesh.new()
	ear.radius = 0.08
	_mesh(head, ear, fur, Vector3(-0.2, 0.06, -0.02), Vector3.ZERO, Vector3(0.7, 1.15, 0.45))
	_mesh(head, ear.duplicate(), fur, Vector3(0.2, 0.06, -0.02), Vector3.ZERO, Vector3(0.7, 1.15, 0.45))
	_mesh(head, SphereMesh.new(), dark, Vector3(-0.06, 0.02, 0.2), Vector3.ZERO, Vector3(0.35, 0.4, 0.25))
	_mesh(head, SphereMesh.new(), dark, Vector3(0.06, 0.02, 0.2), Vector3.ZERO, Vector3(0.35, 0.4, 0.25))
	for side in [-1, 1]:
		var arm := _pivot(p, "ArmL" if side < 0 else "ArmR", Vector3(0.28 * side, 0.92, 0.04))
		var upper := CapsuleMesh.new()
		upper.radius = 0.065
		upper.height = 0.42
		_mesh(arm, upper, fur, Vector3(0.02 * side, -0.18, 0.02), Vector3(12, 0, 18 * side))
		var hand := SphereMesh.new()
		hand.radius = 0.055
		_mesh(arm, hand, skin, Vector3(0.12 * side, -0.4, 0.08))
	for side in [-1.0, 1.0]:
		var leg := _pivot(p, "LegL" if side < 0 else "LegR", Vector3(0.12 * side, 0.42, 0.02))
		var thigh := CapsuleMesh.new()
		thigh.radius = 0.075
		thigh.height = 0.38
		_mesh(leg, thigh, fur, Vector3(0, -0.16, 0))
		var foot := SphereMesh.new()
		foot.radius = 0.06
		_mesh(leg, foot, skin, Vector3(0, -0.38, 0.04), Vector3.ZERO, Vector3(0.9, 0.5, 1.4))
	var tail := _pivot(p, "Tail", Vector3(0.04, 0.72, -0.28))
	var tmesh := CapsuleMesh.new()
	tmesh.radius = 0.04
	tmesh.height = 0.95
	_mesh(tail, tmesh, fur, Vector3(0.1, 0.05, -0.28), Vector3(48, 25, 0))


static func _snake(p: Node3D) -> void:
	p.scale = Vector3(1.35, 1.35, 1.35)
	var scales := MaterialLibrary.animal("snake_scales.png", Color(0.95, 1.0, 0.9), 0.55)
	var belly := MaterialLibrary.animal("snake_scales.png", Color(0.75, 0.7, 0.45), 0.62)
	var segs := Node3D.new()
	segs.name = "Segments"
	p.add_child(segs)
	for i in range(14):
		var sph := SphereMesh.new()
		sph.radius = 0.17 - i * 0.006
		var mat := scales if i % 2 == 0 else belly
		_mesh(segs, sph, mat, Vector3(0, 0.17, -i * 0.26))
	var head := _pivot(p, "Head", Vector3(0, 0.2, 0.28))
	var hd := SphereMesh.new()
	hd.radius = 0.2
	_mesh(head, hd, scales, Vector3.ZERO, Vector3.ZERO, Vector3(0.82, 0.68, 1.25))
	var jaw := SphereMesh.new()
	jaw.radius = 0.1
	_mesh(head, jaw, belly, Vector3(0, -0.06, 0.16), Vector3.ZERO, Vector3(0.9, 0.55, 1.1))
	var gold := StandardMaterial3D.new()
	gold.albedo_color = Color(0.85, 0.78, 0.18)
	gold.roughness = 0.32
	gold.emission_enabled = false
	_mesh(head, SphereMesh.new(), gold, Vector3(-0.1, 0.06, 0.16), Vector3.ZERO, Vector3(0.45, 0.4, 0.35))
	_mesh(head, SphereMesh.new(), gold, Vector3(0.1, 0.06, 0.16), Vector3.ZERO, Vector3(0.45, 0.4, 0.35))
	var tongue := StandardMaterial3D.new()
	tongue.albedo_color = Color(0.7, 0.18, 0.16)
	tongue.roughness = 0.4
	var t := BoxMesh.new()
	t.size = Vector3(0.02, 0.01, 0.16)
	_mesh(head, t, tongue, Vector3(0, -0.02, 0.34), Vector3.ZERO, Vector3.ONE, "Tongue")
