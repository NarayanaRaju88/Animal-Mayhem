class_name ClimbLedge
extends StaticBody3D

var used := false
var top_marker: Marker3D


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(4.2, 4.4, 3.2)
	shape.shape = box
	shape.position = Vector3(0, 2.2, 0)
	add_child(shape)
	var wall := MaterialLibrary.pbr("rock_wall_02", 0.85)
	wall.albedo_color = Color(0.88, 0.86, 0.8)
	wall.roughness = 0.92
	var moss := MaterialLibrary.pbr("forest_leaves_03", 1.1)
	moss.albedo_color = Color(0.55, 0.65, 0.4)
	moss.roughness = 0.9
	moss.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	var aerial := MaterialLibrary.pbr("aerial_rocks_02", 0.7)
	aerial.albedo_color = Color(0.84, 0.82, 0.76)
	aerial.roughness = 0.9
	var chunk := BoxMesh.new()
	chunk.size = Vector3.ONE
	var rng := RandomNumberGenerator.new()
	rng.seed = 24
	for i in 7:
		var mi := MeshInstance3D.new()
		mi.mesh = chunk
		mi.material_override = wall if i % 2 == 0 else aerial
		mi.scale = Vector3(
			rng.randf_range(1.05, 1.85),
			rng.randf_range(0.42, 0.82),
			rng.randf_range(0.95, 1.65)
		)
		mi.position = Vector3(
			rng.randf_range(-1.45, 1.45),
			0.28 + i * 0.54 + rng.randf_range(-0.06, 0.08),
			rng.randf_range(-0.85, 0.95)
		)
		mi.rotation_degrees = Vector3(
			rng.randf_range(-22, 22),
			rng.randf() * 360.0,
			rng.randf_range(-18, 18)
		)
		mi.cast_shadow = (
			GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			if i < 3
			else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		)
		add_child(mi)
	var chip := MeshInstance3D.new()
	chip.mesh = chunk
	chip.material_override = aerial
	chip.scale = Vector3(0.7, 0.32, 0.55)
	chip.position = Vector3(-1.7, 1.15, 0.55)
	chip.rotation_degrees = Vector3(-18, 40, 12)
	chip.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(chip)
	var lip := BoxMesh.new()
	lip.size = Vector3(4.3, 0.28, 1.2)
	var mi2 := MeshInstance3D.new()
	mi2.mesh = lip
	mi2.material_override = moss
	mi2.position = Vector3(0, 4.42, 1.05)
	add_child(mi2)
	var root_mesh := CylinderMesh.new()
	root_mesh.top_radius = 0.04
	root_mesh.bottom_radius = 0.07
	root_mesh.height = 1.0
	root_mesh.radial_segments = 6
	var root_mat := MaterialLibrary.pbr("bark_willow", 2.0)
	root_mat.roughness = 0.94
	for k in 5:
		var root := MeshInstance3D.new()
		root.mesh = root_mesh
		root.material_override = root_mat
		root.scale = Vector3(1.0, rng.randf_range(1.4, 2.4), 1.0)
		root.position = Vector3(rng.randf_range(-1.5, 1.5), 2.4, 1.35)
		root.rotation_degrees = Vector3(18, rng.randf() * 40.0 - 20.0, rng.randf_range(-12, 12))
		root.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(root)
	top_marker = Marker3D.new()
	top_marker.position = Vector3(0, 4.7, 1.35)
	add_child(top_marker)


func climb(animal: AnimalController) -> void:
	if used:
		return
	used = true
	AudioManager.play_sfx("sfx_climb")
	AudioManager.play_animal(&"monkey")
	animal.velocity = Vector3.ZERO
	animal.play_action("climb")
	var tw := create_tween()
	tw.tween_property(animal, "global_position", top_marker.global_position, 1.15)
	tw.finished.connect(func () -> void:
		GameState.mark_climb_done()
	)
