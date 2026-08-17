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
	leaves.radius = 1.1
	var lm := MaterialLibrary.pbr("leafy_grass", 0.9)
	lm.albedo_color = Color(0.42, 0.55, 0.28)
	var canopy := MeshInstance3D.new()
	canopy.mesh = leaves
	canopy.material_override = lm
	canopy.position = Vector3(3.6, 1.1, 0.4)
	_visual.add_child(canopy)


func push(animal: AnimalController) -> void:
	if moved:
		return
	moved = true
	AudioManager.play_sfx("sfx_push")
	AudioManager.play_animal(&"buffalo")
	var tw := create_tween()
	tw.tween_property(self, "position:z", position.z + 6.5, 1.1)
	tw.parallel().tween_property(self, "rotation_degrees:y", 28.0, 1.1)
	tw.finished.connect(func () -> void:
		GameState.mark_tree_cleared()
	)
