class_name AnimalController
extends CharacterBody3D

const GRAVITY := 22.0

var definition: AnimalDefinition
var active := false
var session: JungleWorld
var _visual: Node3D
var _phase := 0.0
var _foot_t := 0.0

var abilities: Array[Ability] = []


func setup(def: AnimalDefinition, player_session: JungleWorld) -> void:
	definition = def
	session = player_session
	name = String(def.id)
	collision_layer = _layer_for(def.id)
	collision_mask = 1
	if def.id != &"snake":
		collision_mask |= 16
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = def.collision_radius
	cap.height = def.collision_height
	col.shape = cap
	col.position = Vector3(0, def.collision_height * 0.5, 0)
	add_child(col)
	_visual = Node3D.new()
	_visual.name = "Visual"
	add_child(_visual)
	AnimalVisuals.build(def.id, _visual)
	for a in def.abilities:
		match a:
			"force":
				abilities.append(ForceAbility.new())
			"climb":
				abilities.append(ClimbAbility.new())
			"coil":
				abilities.append(CoilAbility.new())


func _layer_for(id: StringName) -> int:
	match id:
		&"buffalo":
			return 2
		&"monkey":
			return 4
		&"snake":
			return 8
	return 2


func has_ability(ability_id: String) -> bool:
	for a in abilities:
		if a.id() == ability_id:
			return true
	return definition.abilities.has(ability_id)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0
	var moving := 0.0
	if active and session != null:
		var stick: Vector2 = session.move_vector
		var cam: Node3D = session.camera
		var basis := cam.global_transform.basis
		var fwd := -basis.z
		fwd.y = 0.0
		fwd = fwd.normalized()
		var right := basis.x
		right.y = 0.0
		right = right.normalized()
		var dir := fwd * -stick.y + right * stick.x
		if dir.length() > 0.12:
			dir = dir.normalized()
			velocity.x = dir.x * definition.move_speed
			velocity.z = dir.z * definition.move_speed
			var target_yaw := atan2(dir.x, dir.z)
			rotation.y = lerp_angle(rotation.y, target_yaw, definition.turn_speed * delta)
			moving = dir.length()
		else:
			velocity.x = move_toward(velocity.x, 0.0, definition.move_speed * 4.0 * delta)
			velocity.z = move_toward(velocity.z, 0.0, definition.move_speed * 4.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 8.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 8.0 * delta)
	move_and_slide()
	_animate(delta, moving)


func _animate(delta: float, moving: float) -> void:
	_phase += delta * (8.0 if moving > 0.1 else 2.2)
	var breath := sin(_phase) * 0.015
	if definition.id == &"snake":
		_visual.position.y = 0.02 + abs(sin(_phase * 1.4)) * (0.06 if moving > 0.1 else 0.02)
		var segs := _visual.get_node_or_null("Segments")
		if segs:
			var i := 0
			for c in segs.get_children():
				c.position.x = sin(_phase * 2.0 + i * 0.7) * (0.12 if moving > 0.1 else 0.04)
				i += 1
	else:
		_visual.position.y = breath
		if moving > 0.1:
			_visual.rotation_degrees.z = sin(_phase * 2.0) * 4.0
			_foot_t += delta
			if _foot_t > 0.38:
				_foot_t = 0.0
				if active:
					AudioManager.play_sfx("sfx_footstep")
		else:
			_visual.rotation_degrees.z = lerp(_visual.rotation_degrees.z, 0.0, 8.0 * delta)
