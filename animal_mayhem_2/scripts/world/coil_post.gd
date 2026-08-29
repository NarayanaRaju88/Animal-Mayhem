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
	wood.albedo_color = Color(0.78, 0.66, 0.5)
	wood.roughness = 0.94
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.16
	mesh.bottom_radius = 0.2
	mesh.height = 1.6
	mesh.radial_segments = 8
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = wood
	mi.position = Vector3(0, 0.8, 0)
	add_child(mi)
	var base := MeshInstance3D.new()
	var basem := CylinderMesh.new()
	basem.top_radius = 0.26
	basem.bottom_radius = 0.3
	basem.height = 0.1
	base.mesh = basem
	base.material_override = wood
	base.position = Vector3(0, 0.05, 0)
	add_child(base)
	var ring := TorusMesh.new()
	ring.inner_radius = 0.18
	ring.outer_radius = 0.32
	var bronze := StandardMaterial3D.new()
	bronze.albedo_color = Color(0.62, 0.48, 0.22)
	bronze.metallic = 0.18
	bronze.roughness = 0.62
	var rmi := MeshInstance3D.new()
	rmi.name = "Ring"
	rmi.mesh = ring
	rmi.material_override = bronze
	rmi.position = Vector3(0, 1.15, 0)
	rmi.rotation_degrees = Vector3(90, 0, 0)
	add_child(rmi)
	var wrap_mat := MaterialLibrary.pbr("forest_leaves_03", 2.2)
	wrap_mat.albedo_color = Color(0.4, 0.5, 0.28)
	wrap_mat.roughness = 0.9
	wrap_mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	var wrapm := CylinderMesh.new()
	wrapm.top_radius = 0.04
	wrapm.bottom_radius = 0.05
	wrapm.height = 1.35
	wrapm.radial_segments = 6
	for w in 2:
		var wrap := MeshInstance3D.new()
		wrap.mesh = wrapm
		wrap.material_override = wrap_mat
		wrap.position = Vector3(0.12 if w == 0 else -0.1, 0.7, 0.04)
		wrap.rotation_degrees = Vector3(8, 180.0 * w, 18 if w == 0 else -16)
		wrap.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(wrap)
	var fern := CapsuleMesh.new()
	fern.radius = 0.16
	fern.height = 0.42
	fern.radial_segments = 6
	for f in 3:
		var tuft := MeshInstance3D.new()
		tuft.mesh = fern
		tuft.material_override = wrap_mat
		var ang := f * TAU / 3.0 + 0.4
		tuft.position = Vector3(cos(ang) * 0.42, 0.16, sin(ang) * 0.42)
		tuft.scale = Vector3(0.85, 0.7, 0.9)
		tuft.rotation_degrees = Vector3(18, f * 80.0, -10)
		tuft.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(tuft)


func coil(animal: AnimalController) -> void:
	if coiled:
		return
	coiled = true
	AudioManager.play_sfx("sfx_coil")
	AudioManager.play_animal(&"snake")
	animal.play_action("coil")
	var tw := create_tween()
	tw.tween_property(animal, "global_position", global_position + Vector3(0.35, 0.05, 0), 0.45)
	tw.tween_callback(func () -> void:
		AudioManager.play_sfx("sfx_gate")
		if vine_gate:
			var gtw := create_tween()
			gtw.tween_property(vine_gate, "position:y", vine_gate.position.y - 5.0, 1.2)
		GameState.mark_coil_done()
	)
