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
	var rock := MaterialLibrary.pbr("mossy_rock", 0.65)
	var mesh := BoxMesh.new()
	mesh.size = Vector3(4.2, 4.4, 3.2)
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = rock
	mi.position = Vector3(0, 2.2, 0)
	add_child(mi)
	var lip := BoxMesh.new()
	lip.size = Vector3(4.4, 0.25, 1.1)
	var mi2 := MeshInstance3D.new()
	mi2.mesh = lip
	var moss := MaterialLibrary.pbr("leafy_grass", 1.3)
	moss.albedo_color = Color(0.4, 0.52, 0.28)
	mi2.material_override = moss
	mi2.position = Vector3(0, 4.45, 1.1)
	add_child(mi2)
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
	var tw := create_tween()
	tw.tween_property(animal, "global_position", top_marker.global_position, 1.15)
	tw.finished.connect(func () -> void:
		GameState.mark_climb_done()
	)
