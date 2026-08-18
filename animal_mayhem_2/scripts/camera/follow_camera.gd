class_name FollowCamera
extends Node3D
## Third-person adventure camera. Animal stays readable; jungle fills most of the frame.

var target: Node3D
var distance := 9.4
var height := 3.05
var yaw := 2.55
var pitch := -0.22
var _look_drag := Vector2.ZERO
var _cam: Camera3D


func _ready() -> void:
	_cam = Camera3D.new()
	_cam.name = "Camera3D"
	_cam.fov = 55.0
	_cam.near = 0.15
	_cam.far = 240.0
	add_child(_cam)


func add_look(delta: Vector2) -> void:
	_look_drag += delta


func _process(delta: float) -> void:
	if target == null:
		return
	yaw -= _look_drag.x * 0.0042
	pitch = clampf(pitch - _look_drag.y * 0.0032, -0.58, 0.08)
	_look_drag = Vector2.ZERO
	var look_height := height * 0.38
	var pivot := target.global_position + Vector3(0.0, look_height, 0.0)
	var offset := Vector3(
		sin(yaw) * cos(pitch) * distance,
		height + sin(-pitch) * distance * 0.22,
		cos(yaw) * cos(pitch) * distance
	)
	var desired := pivot + offset
	var space := get_world_3d().direct_space_state
	if space != null:
		var q := PhysicsRayQueryParameters3D.create(pivot, desired)
		q.collision_mask = 1
		q.exclude = _exclude_target()
		var hit := space.intersect_ray(q)
		if not hit.is_empty():
			var pulled: Vector3 = hit.position + (hit.normal as Vector3) * 0.55
			if pulled.distance_to(pivot) > 2.4:
				desired = pulled
	global_position = global_position.lerp(desired, 1.0 - exp(-delta * 4.6))
	var look_at_pos := target.global_position + Vector3(0.0, look_height, 0.0)
	if global_position.distance_to(look_at_pos) > 0.12:
		look_at(look_at_pos)


func _exclude_target() -> Array[RID]:
	var out: Array[RID] = []
	if target is CollisionObject3D:
		out.append((target as CollisionObject3D).get_rid())
	return out
