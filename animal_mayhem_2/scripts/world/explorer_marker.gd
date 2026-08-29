class_name ExplorerMarker
extends Area3D


func _ready() -> void:
	monitoring = true
	# Animals use layers 2/4/8 (buffalo/monkey/snake). Default mask 1 never sees them.
	collision_mask = 2 | 4 | 8
	var col := CollisionShape3D.new()
	var sph := SphereShape3D.new()
	sph.radius = 1.8
	col.shape = sph
	add_child(col)
	var dirt := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 2.4
	disc.bottom_radius = 2.4
	disc.height = 0.06
	dirt.mesh = disc
	dirt.material_override = MaterialLibrary.pbr("brown_mud_03", 2.2)
	dirt.position = Vector3(0, 0.02, 0)
	add_child(dirt)
	var cloth := StandardMaterial3D.new()
	cloth.albedo_color = Color(0.5, 0.4, 0.26)
	cloth.roughness = 0.92
	var tent := MeshInstance3D.new()
	var prism := PrismMesh.new()
	prism.size = Vector3(1.6, 0.85, 1.4)
	tent.mesh = prism
	tent.material_override = cloth
	tent.position = Vector3(-1.3, 0.42, -0.8)
	tent.rotation_degrees = Vector3(12, 28, 8)
	tent.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(tent)
	var pack := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.45, 0.38, 0.32)
	pack.mesh = box
	pack.material_override = MaterialLibrary.pbr("bark_willow", 1.8)
	pack.position = Vector3(0.7, 0.22, -0.5)
	add_child(pack)
	var pole := MeshInstance3D.new()
	var stick := CylinderMesh.new()
	stick.top_radius = 0.03
	stick.bottom_radius = 0.04
	stick.height = 1.6
	pole.mesh = stick
	pole.material_override = MaterialLibrary.pbr("bark_brown_01", 2.0)
	pole.position = Vector3(1.1, 0.8, 0.4)
	add_child(pole)
	var flag := MeshInstance3D.new()
	var fl := BoxMesh.new()
	fl.size = Vector3(0.45, 0.28, 0.02)
	flag.mesh = fl
	var fm := StandardMaterial3D.new()
	fm.albedo_color = Color(0.55, 0.22, 0.16)
	fm.roughness = 0.85
	flag.material_override = fm
	flag.position = Vector3(1.32, 1.42, 0.4)
	add_child(flag)
	var body := CapsuleMesh.new()
	body.radius = 0.2
	body.height = 0.95
	var mi := MeshInstance3D.new()
	mi.mesh = body
	mi.material_override = cloth
	mi.position = Vector3(0, 0.55, 0.15)
	mi.rotation_degrees = Vector3(12, 0, 0)
	add_child(mi)
	var head := SphereMesh.new()
	head.radius = 0.14
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.74, 0.56, 0.42)
	skin.roughness = 0.7
	var h := MeshInstance3D.new()
	h.mesh = head
	h.material_override = skin
	h.position = Vector3(0, 1.12, 0.22)
	add_child(h)
	var hat := CylinderMesh.new()
	hat.top_radius = 0.16
	hat.bottom_radius = 0.26
	hat.height = 0.1
	var hm := MeshInstance3D.new()
	hm.mesh = hat
	var hatm := StandardMaterial3D.new()
	hatm.albedo_color = Color(0.28, 0.2, 0.1)
	hatm.roughness = 0.9
	hm.material_override = hatm
	hm.position = Vector3(0, 1.24, 0.2)
	add_child(hm)
	body_entered.connect(_on_enter)


func _physics_process(_delta: float) -> void:
	if not GameState.coil_done or GameState.step == GameState.Step.DONE:
		return
	for body in get_overlapping_bodies():
		if body is AnimalController:
			GameState.mark_complete()
			return


func _on_enter(body: Node) -> void:
	if body is AnimalController and GameState.coil_done:
		GameState.mark_complete()
