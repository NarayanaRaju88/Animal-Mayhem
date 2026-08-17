class_name AnimalVisuals
extends RefCounted
## Project-owned semi-realistic meshes. Swap for licensed GLTF later.


static func build(kind: StringName, parent: Node3D) -> void:
	match kind:
		&"buffalo":
			_buffalo(parent)
		&"monkey":
			_monkey(parent)
		&"snake":
			_snake(parent)


static func _mat(color: Color, rough := 0.72, spec := 0.25) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	m.metallic = 0.0
	m.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	m.rim_enabled = true
	m.rim = spec
	m.rim_tint = 0.4
	return m


static func _mesh(parent: Node3D, mesh: Mesh, mat: Material, pos: Vector3, rot := Vector3.ZERO, scale := Vector3.ONE) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot
	mi.scale = scale
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)
	return mi


static func _buffalo(p: Node3D) -> void:
	var hide := _mat(Color(0.22, 0.13, 0.07))
	var dark := _mat(Color(0.12, 0.07, 0.04), 0.8)
	var horn := _mat(Color(0.86, 0.78, 0.62), 0.35)
	var body := CapsuleMesh.new()
	body.radius = 0.62
	body.height = 2.15
	_mesh(p, body, hide, Vector3(0, 0.85, 0.1), Vector3(90, 0, 0))
	var head := SphereMesh.new()
	head.radius = 0.42
	head.height = 0.84
	_mesh(p, head, hide, Vector3(0, 1.15, 1.05), Vector3.ZERO, Vector3(1.05, 0.9, 1.15))
	var snout := CapsuleMesh.new()
	snout.radius = 0.18
	snout.height = 0.55
	_mesh(p, snout, dark, Vector3(0, 0.98, 1.42), Vector3(80, 0, 0))
	var h1 := CapsuleMesh.new()
	h1.radius = 0.07
	h1.height = 0.85
	_mesh(p, h1, horn, Vector3(-0.28, 1.48, 0.95), Vector3(20, 0, 55))
	_mesh(p, h1.duplicate(), horn, Vector3(0.28, 1.48, 0.95), Vector3(20, 0, -55))
	var hump := SphereMesh.new()
	hump.radius = 0.38
	_mesh(p, hump, dark, Vector3(0, 1.28, -0.15), Vector3.ZERO, Vector3(1.2, 0.7, 0.9))
	var leg := CylinderMesh.new()
	leg.top_radius = 0.12
	leg.bottom_radius = 0.14
	leg.height = 0.7
	for x in [-0.38, 0.38]:
		for z in [-0.55, 0.55]:
			_mesh(p, leg.duplicate(), dark, Vector3(x, 0.35, z))
	var tail := CapsuleMesh.new()
	tail.radius = 0.06
	tail.height = 0.7
	_mesh(p, tail, hide, Vector3(0, 1.05, -1.05), Vector3(35, 0, 0))


static func _monkey(p: Node3D) -> void:
	var fur := _mat(Color(0.42, 0.26, 0.12))
	var skin := _mat(Color(0.82, 0.62, 0.42), 0.55)
	var dark := _mat(Color(0.18, 0.1, 0.06))
	var torso := CapsuleMesh.new()
	torso.radius = 0.22
	torso.height = 0.72
	_mesh(p, torso, fur, Vector3(0, 0.62, 0))
	var head := SphereMesh.new()
	head.radius = 0.2
	_mesh(p, head, fur, Vector3(0, 1.12, 0.06))
	var face := SphereMesh.new()
	face.radius = 0.14
	_mesh(p, face, skin, Vector3(0, 1.08, 0.16), Vector3.ZERO, Vector3(0.9, 0.85, 0.7))
	var ear := SphereMesh.new()
	ear.radius = 0.07
	_mesh(p, ear, fur, Vector3(-0.18, 1.16, 0.0))
	_mesh(p, ear.duplicate(), fur, Vector3(0.18, 1.16, 0.0))
	var arm := CapsuleMesh.new()
	arm.radius = 0.06
	arm.height = 0.62
	_mesh(p, arm, fur, Vector3(-0.28, 0.7, 0.05), Vector3(15, 0, 25))
	_mesh(p, arm.duplicate(), fur, Vector3(0.28, 0.7, 0.05), Vector3(15, 0, -25))
	var leg := CapsuleMesh.new()
	leg.radius = 0.07
	leg.height = 0.5
	_mesh(p, leg, fur, Vector3(-0.12, 0.28, 0.02), Vector3(8, 0, 0))
	_mesh(p, leg.duplicate(), fur, Vector3(0.12, 0.28, 0.02), Vector3(8, 0, 0))
	var tail := CapsuleMesh.new()
	tail.radius = 0.045
	tail.height = 0.85
	_mesh(p, tail, fur, Vector3(0.05, 0.7, -0.42), Vector3(55, 20, 0))
	var eye := SphereMesh.new()
	eye.radius = 0.03
	_mesh(p, eye, dark, Vector3(-0.05, 1.12, 0.24))
	_mesh(p, eye.duplicate(), dark, Vector3(0.05, 1.12, 0.24))


static func _snake(p: Node3D) -> void:
	var scale := _mat(Color(0.22, 0.42, 0.18), 0.45)
	var stripe := _mat(Color(0.72, 0.78, 0.28), 0.4)
	var head_m := _mat(Color(0.28, 0.48, 0.2), 0.4)
	var segs := Node3D.new()
	segs.name = "Segments"
	p.add_child(segs)
	for i in range(10):
		var sph := SphereMesh.new()
		sph.radius = 0.16 - i * 0.008
		var mat := stripe if i % 2 == 0 else scale
		_mesh(segs, sph, mat, Vector3(0, 0.16, -i * 0.28))
	var head := SphereMesh.new()
	head.radius = 0.2
	_mesh(p, head, head_m, Vector3(0, 0.2, 0.22), Vector3.ZERO, Vector3(0.85, 0.7, 1.15))
	var eye := SphereMesh.new()
	eye.radius = 0.035
	var gold := _mat(Color(0.9, 0.85, 0.2), 0.3)
	_mesh(p, eye, gold, Vector3(-0.1, 0.28, 0.34))
	_mesh(p, eye.duplicate(), gold, Vector3(0.1, 0.28, 0.34))
