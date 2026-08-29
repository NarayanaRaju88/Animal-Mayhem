class_name FallenTree
extends StaticBody3D

var moved := false
var _visual: Node3D


func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.2, 1.1, 8.5)
	shape.shape = box
	shape.position = Vector3(0, 0.55, 0)
	add_child(shape)
	_visual = Node3D.new()
	add_child(_visual)
	var bark := MaterialLibrary.pbr("bark_willow", 1.4)
	bark.albedo_color = Color(0.82, 0.74, 0.62)
	bark.roughness = 0.94
	var heart := MaterialLibrary.pbr("bark_brown_01", 2.2)
	heart.albedo_color = Color(0.55, 0.4, 0.26)
	heart.roughness = 0.92
	var leaf := MaterialLibrary.pbr("forest_leaves_03", 0.9)
	leaf.albedo_color = Color(0.42, 0.55, 0.28)
	leaf.roughness = 0.88
	leaf.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	var logm := CylinderMesh.new()
	logm.top_radius = 0.42
	logm.bottom_radius = 0.48
	logm.height = 8.4
	logm.radial_segments = 10
	var mi := MeshInstance3D.new()
	mi.mesh = logm
	mi.material_override = bark
	mi.rotation_degrees = Vector3(90, 0, 0)
	mi.position = Vector3(0, 0.48, 0)
	_visual.add_child(mi)
	var cap := MeshInstance3D.new()
	var capm := CylinderMesh.new()
	capm.top_radius = 0.36
	capm.bottom_radius = 0.4
	capm.height = 0.08
	cap.mesh = capm
	cap.material_override = heart
	cap.rotation_degrees = Vector3(90, 0, 0)
	cap.position = Vector3(0, 0.48, 4.18)
	_visual.add_child(cap)
	var splinter := CylinderMesh.new()
	splinter.top_radius = 0.04
	splinter.bottom_radius = 0.09
	splinter.height = 0.7
	splinter.radial_segments = 6
	for s in 3:
		var sp := MeshInstance3D.new()
		sp.mesh = splinter
		sp.material_override = bark
		sp.position = Vector3((-1 + s) * 0.12, 0.52, 4.35)
		sp.rotation_degrees = Vector3(78 + s * 8, 40 * s, -12 + s * 10)
		sp.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_visual.add_child(sp)
	var cap_mesh := CapsuleMesh.new()
	cap_mesh.radius = 0.55
	cap_mesh.height = 1.35
	cap_mesh.radial_segments = 7
	for k in 3:
		var canopy := MeshInstance3D.new()
		canopy.mesh = cap_mesh
		canopy.material_override = leaf
		canopy.position = Vector3((k - 1) * 0.4, 0.82, 3.15 + k * 0.28)
		canopy.scale = Vector3(1.05 + k * 0.1, 0.72, 0.95)
		canopy.rotation_degrees = Vector3(18, 50 * k, -12)
		canopy.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_visual.add_child(canopy)
	var branch := CylinderMesh.new()
	branch.top_radius = 0.05
	branch.bottom_radius = 0.09
	branch.height = 1.0
	branch.radial_segments = 6
	for i in 4:
		var br := MeshInstance3D.new()
		br.mesh = branch
		br.material_override = bark
		br.scale = Vector3(1.0, 1.4 + i * 0.25, 1.0)
		br.position = Vector3(0.15 * (1 if i % 2 == 0 else -1), 0.7, -1.6 + i * 0.9)
		br.rotation_degrees = Vector3(70, 40 * i, 18)
		br.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_visual.add_child(br)
	var rootball := MeshInstance3D.new()
	var rb := SphereMesh.new()
	rb.radius = 0.55
	rootball.mesh = rb
	rootball.material_override = bark
	rootball.position = Vector3(0, 0.32, -3.8)
	rootball.scale = Vector3(1.2, 0.7, 1.1)
	_visual.add_child(rootball)
	var flare := CylinderMesh.new()
	flare.top_radius = 0.05
	flare.bottom_radius = 0.11
	flare.height = 0.85
	flare.radial_segments = 6
	for r in 3:
		var root_m := MeshInstance3D.new()
		root_m.mesh = flare
		root_m.material_override = bark
		root_m.position = Vector3(0, 0.12, -3.9)
		root_m.rotation_degrees = Vector3(75, r * 120.0, 8)
		root_m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_visual.add_child(root_m)


func push(animal: AnimalController) -> void:
	if moved:
		return
	moved = true
	AudioManager.play_sfx("sfx_push")
	AudioManager.play_animal(&"buffalo")
	animal.play_action("push")
	var dust := GPUParticles3D.new()
	dust.amount = 18
	dust.lifetime = 0.9
	dust.one_shot = true
	dust.emitting = true
	var pm := ParticleProcessMaterial.new()
	pm.direction = Vector3(0, 1, 0.4)
	pm.spread = 50.0
	pm.initial_velocity_min = 0.4
	pm.initial_velocity_max = 1.4
	pm.gravity = Vector3(0, -2.0, 0)
	pm.scale_min = 0.06
	pm.scale_max = 0.16
	pm.color = Color(0.42, 0.34, 0.22, 0.4)
	dust.process_material = pm
	var sm := SphereMesh.new()
	sm.radius = 0.06
	sm.height = 0.12
	dust.draw_pass_1 = sm
	dust.position = Vector3(0, 0.4, 0)
	add_child(dust)
	var tw := create_tween()
	tw.tween_property(self, "position:z", position.z + 6.5, 1.1)
	tw.parallel().tween_property(self, "rotation_degrees:y", 28.0, 1.1)
	tw.finished.connect(func () -> void:
		GameState.mark_tree_cleared()
	)
