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
	var logm := CylinderMesh.new()
	logm.top_radius = 0.42
	logm.bottom_radius = 0.48
	logm.height = 8.4
	var mi := MeshInstance3D.new()
	mi.mesh = logm
	mi.material_override = bark
	mi.rotation_degrees = Vector3(0, 0, 90)
	mi.position = Vector3(0, 0.48, 0)
	_visual.add_child(mi)
	var leaves := SphereMesh.new()
	leaves.radius = 0.85
	var lm := MaterialLibrary.pbr("leafy_grass", 0.9)
	lm.albedo_color = Color(0.42, 0.55, 0.28)
	for k in 3:
		var canopy := MeshInstance3D.new()
		canopy.mesh = leaves
		canopy.material_override = lm
		canopy.position = Vector3(3.2 + k * 0.35, 0.85, (k - 1) * 0.45)
		canopy.scale = Vector3(1.3 + k * 0.15, 0.38, 1.1)
		canopy.rotation_degrees = Vector3(12, 40 * k, -8)
		_visual.add_child(canopy)
	for i in 4:
		var br := MeshInstance3D.new()
		var bc := CylinderMesh.new()
		bc.top_radius = 0.05
		bc.bottom_radius = 0.09
		bc.height = 1.4 + i * 0.25
		br.mesh = bc
		br.material_override = bark
		br.position = Vector3(-1.2 + i * 0.9, 0.7, 0.15 * (1 if i % 2 == 0 else -1))
		br.rotation_degrees = Vector3(70, 40 * i, 18)
		_visual.add_child(br)
	var rootball := MeshInstance3D.new()
	var rb := SphereMesh.new()
	rb.radius = 0.55
	rootball.mesh = rb
	rootball.material_override = bark
	rootball.position = Vector3(-3.8, 0.35, 0)
	rootball.scale = Vector3(1.2, 0.7, 1.1)
	_visual.add_child(rootball)


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
