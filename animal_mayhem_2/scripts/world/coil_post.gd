class_name CoilPost
extends StaticBody3D

var coiled := false
var vine_gate: Node3D


func _ready() -> void:
	collision_layer = 1
	var col := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 0.22
	cyl.height = 1.6
	col.shape = cyl
	col.position = Vector3(0, 0.8, 0)
	add_child(col)
	var wood := MaterialLibrary.pbr("bark_brown_01", 1.8)
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.16
	mesh.bottom_radius = 0.2
	mesh.height = 1.6
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = wood
	mi.position = Vector3(0, 0.8, 0)
	add_child(mi)
	var ring := TorusMesh.new()
	ring.inner_radius = 0.18
	ring.outer_radius = 0.32
	var bronze := StandardMaterial3D.new()
	bronze.albedo_color = Color(0.72, 0.55, 0.22)
	bronze.metallic = 0.4
	bronze.roughness = 0.4
	var rmi := MeshInstance3D.new()
	rmi.name = "Ring"
	rmi.mesh = ring
	rmi.material_override = bronze
	rmi.position = Vector3(0, 1.15, 0)
	rmi.rotation_degrees = Vector3(90, 0, 0)
	add_child(rmi)


func coil(animal: AnimalController) -> void:
	if coiled:
		return
	coiled = true
	AudioManager.play_sfx("sfx_coil")
	AudioManager.play_animal(&"snake")
	var tw := create_tween()
	tw.tween_property(animal, "global_position", global_position + Vector3(0.35, 0.05, 0), 0.45)
	tw.tween_callback(func () -> void:
		AudioManager.play_sfx("sfx_gate")
		if vine_gate:
			var gtw := create_tween()
			gtw.tween_property(vine_gate, "position:y", vine_gate.position.y - 5.0, 1.2)
		GameState.mark_coil_done()
	)
