class_name FollowCamera
extends Node3D

var target: Node3D
var distance := 7.0
var height := 2.4
var yaw := 2.6
var pitch := -0.35
var _look_drag := Vector2.ZERO


func _ready() -> void:
	var cam := Camera3D.new()
	cam.name = "Camera3D"
	cam.fov = 52.0
	cam.near = 0.12
	cam.far = 220.0
	add_child(cam)


func add_look(delta: Vector2) -> void:
	_look_drag += delta


func _process(delta: float) -> void:
	if target == null:
		return
	yaw -= _look_drag.x * 0.005
	pitch = clampf(pitch - _look_drag.y * 0.004, -0.85, 0.15)
	_look_drag = Vector2.ZERO
	var offset := Vector3(
		sin(yaw) * cos(pitch) * distance,
		height + sin(-pitch) * distance * 0.35,
		cos(yaw) * cos(pitch) * distance
	)
	var desired := target.global_position + offset
	global_position = global_position.lerp(desired, 1.0 - exp(-delta * 5.5))
	var look_at_pos := target.global_position + Vector3(0, height * 0.45, 0)
	look_at(look_at_pos)
