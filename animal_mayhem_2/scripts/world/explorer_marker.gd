class_name ExplorerMarker
extends Area3D


func _ready() -> void:
	monitoring = true
	var col := CollisionShape3D.new()
	var sph := SphereShape3D.new()
	sph.radius = 1.8
	col.shape = sph
	add_child(col)
	var cloth := StandardMaterial3D.new()
	cloth.albedo_color = Color(0.45, 0.38, 0.22)
	var body := CapsuleMesh.new()
	body.radius = 0.22
	body.height = 1.15
	var mi := MeshInstance3D.new()
	mi.mesh = body
	mi.material_override = cloth
	mi.position = Vector3(0, 0.7, 0)
	add_child(mi)
	var head := SphereMesh.new()
	head.radius = 0.16
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.76, 0.58, 0.42)
	var h := MeshInstance3D.new()
	h.mesh = head
	h.material_override = skin
	h.position = Vector3(0, 1.38, 0)
	add_child(h)
	var hat := CylinderMesh.new()
	hat.top_radius = 0.18
	hat.bottom_radius = 0.28
	hat.height = 0.12
	var hm := MeshInstance3D.new()
	hm.mesh = hat
	var hatm := StandardMaterial3D.new()
	hatm.albedo_color = Color(0.28, 0.2, 0.1)
	hm.material_override = hatm
	hm.position = Vector3(0, 1.52, 0)
	add_child(hm)
	body_entered.connect(_on_enter)


func _on_enter(body: Node) -> void:
	if body is AnimalController and GameState.coil_done:
		GameState.mark_complete()
