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
	var moss := MaterialLibrary.pbr("forest_leaves_03", 1.1)
	moss.albedo_color = Color(0.55, 0.65, 0.4)
	var aerial := MaterialLibrary.pbr("aerial_rocks_02", 0.7)
	var rng := RandomNumberGenerator.new()
	rng.seed = 24
	for i in 7:
		var mi := MeshInstance3D.new()
		var slab := BoxMesh.new()
		slab.size = Vector3(
			rng.randf_range(1.05, 1.85),
			rng.randf_range(0.42, 0.78),
			rng.randf_range(0.95, 1.65)
		)
		mi.mesh = slab
		mi.material_override = wall if i % 2 == 0 else aerial
		mi.position = Vector3(rng.randf_range(-1.6, 1.6), 0.55 + i * 0.52, rng.randf_range(-1.0, 1.0))
		mi.rotation_degrees = Vector3(rng.randf_range(-16, 16), rng.randf() * 360.0, rng.randf_range(-12, 12))
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		add_child(mi)
	var lip := BoxMesh.new()
	lip.size = Vector3(4.3, 0.28, 1.2)
	var mi2 := MeshInstance3D.new()
	mi2.mesh = lip
	mi2.material_override = moss
	mi2.position = Vector3(0, 4.42, 1.05)
	add_child(mi2)
	for k in 5:
		var root := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.04
		cyl.bottom_radius = 0.07
		cyl.height = rng.randf_range(1.4, 2.4)
		root.mesh = cyl
		root.material_override = MaterialLibrary.pbr("bark_willow", 2.0)
		root.position = Vector3(rng.randf_range(-1.5, 1.5), 2.4, 1.35)
		root.rotation_degrees = Vector3(18, rng.randf() * 40.0 - 20.0, rng.randf_range(-12, 12))
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
