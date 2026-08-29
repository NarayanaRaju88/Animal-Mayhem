class_name ObjectiveMarker
extends Node3D
## One lightweight step-driven beacon. Shared primitive meshes only.

var _bob := 0.0
var _beam: MeshInstance3D
var _chevron: MeshInstance3D


func _ready() -> void:
	var gold := StandardMaterial3D.new()
	gold.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gold.albedo_color = Color(1.0, 0.86, 0.32, 0.92)
	gold.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	gold.cull_mode = BaseMaterial3D.CULL_DISABLED
	gold.no_depth_test = false

	var ring_mat := gold.duplicate() as StandardMaterial3D
	ring_mat.albedo_color = Color(1.0, 0.82, 0.28, 0.78)

	var beam_mat := gold.duplicate() as StandardMaterial3D
	beam_mat.albedo_color = Color(1.0, 0.9, 0.4, 0.38)

	var disc := CylinderMesh.new()
	disc.top_radius = 0.55
	disc.bottom_radius = 0.55
	disc.height = 0.06
	disc.radial_segments = 12
	var ring := MeshInstance3D.new()
	ring.mesh = disc
	ring.material_override = ring_mat
	ring.position = Vector3(0, 0.04, 0)
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(ring)

	var shaft := CylinderMesh.new()
	shaft.top_radius = 0.045
	shaft.bottom_radius = 0.07
	shaft.height = 2.4
	shaft.radial_segments = 8
	_beam = MeshInstance3D.new()
	_beam.mesh = shaft
	_beam.material_override = beam_mat
	_beam.position = Vector3(0, 1.25, 0)
	_beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_beam)

	var diamond := PrismMesh.new()
	diamond.size = Vector3(0.55, 0.42, 0.55)
	_chevron = MeshInstance3D.new()
	_chevron.mesh = diamond
	_chevron.material_override = gold
	_chevron.position = Vector3(0, 2.55, 0)
	_chevron.rotation_degrees = Vector3(180, 0, 0)
	_chevron.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_chevron)
	visible = false


func show_at(xz: Vector2, ground_y: float) -> void:
	global_position = Vector3(xz.x, ground_y + 0.02, xz.y)
	visible = true


func hide_marker() -> void:
	visible = false


func _process(delta: float) -> void:
	if not visible:
		return
	_bob += delta * 2.4
	if _chevron:
		_chevron.position.y = 2.55 + sin(_bob) * 0.16
		_chevron.rotation_degrees.y += delta * 48.0
	if _beam and _beam.material_override is StandardMaterial3D:
		var pulse := 0.28 + 0.22 * (0.5 + 0.5 * sin(_bob * 1.6))
		var mat := _beam.material_override as StandardMaterial3D
		mat.albedo_color.a = pulse
