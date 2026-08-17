class_name AnimalController
extends CharacterBody3D

const GRAVITY := 24.0

var definition: AnimalDefinition
var active := false
var session: JungleWorld
var _visual: Node3D
var _phase := 0.0
var _foot_t := 0.0
var _idle_snd := 0.0
var _dust: GPUParticles3D
var action_name := ""
var _action_t := 0.0

var abilities: Array[Ability] = []


func play_action(kind: String) -> void:
	action_name = kind
	_action_t = 0.0


func setup(def: AnimalDefinition, player_session: JungleWorld) -> void:
	definition = def
	session = player_session
	name = String(def.id)
	collision_layer = _layer_for(def.id)
	collision_mask = 1
	if def.id != &"snake":
		collision_mask |= 16
	floor_snap_length = 0.35
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
	if def.id != &"snake":
		_dust = GPUParticles3D.new()
		_dust.amount = 10
		_dust.lifetime = 0.55
		_dust.emitting = false
		var pm := ParticleProcessMaterial.new()
		pm.direction = Vector3(0, 1, -0.4)
		pm.spread = 35.0
		pm.initial_velocity_min = 0.2
		pm.initial_velocity_max = 0.7
		pm.gravity = Vector3(0, -1.2, 0)
		pm.scale_min = 0.04
		pm.scale_max = 0.1
		pm.color = Color(0.45, 0.38, 0.24, 0.35)
		_dust.process_material = pm
		var sm := SphereMesh.new()
		sm.radius = 0.05
		sm.height = 0.1
		_dust.draw_pass_1 = sm
		_dust.position = Vector3(0, 0.08, 0)
		add_child(_dust)
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
	var desired := Vector3(velocity.x, 0.0, velocity.z)
	if active and session != null:
		var stick: Vector2 = session.move_vector
		var cam: Node3D = session.camera
		var basis := cam.global_transform.basis
		var fwd := -basis.z
		fwd.y = 0.0
		if fwd.length() > 0.001:
			fwd = fwd.normalized()
		var right := basis.x
		right.y = 0.0
		if right.length() > 0.001:
			right = right.normalized()
		var dir := fwd * -stick.y + right * stick.x
		if dir.length() > 0.12:
			dir = dir.normalized()
			desired = dir * definition.move_speed
			var target_yaw := atan2(dir.x, dir.z)
			rotation.y = lerp_angle(rotation.y, target_yaw, definition.turn_speed * delta)
			moving = dir.length()
		else:
			desired = Vector3.ZERO
	else:
		desired = Vector3.ZERO
	var accel := 11.0 if desired.length() > 0.1 else 14.0
	velocity.x = move_toward(velocity.x, desired.x, accel * delta * definition.move_speed)
	velocity.z = move_toward(velocity.z, desired.z, accel * delta * definition.move_speed)
	move_and_slide()
	_animate(delta, moving, desired.length())


func _animate(delta: float, moving: float, speed: float) -> void:
	var run := moving > 0.1
	if action_name != "":
		_action_t += delta
		if _action_t > 1.15:
			action_name = ""
	var gait := (speed / maxf(definition.move_speed, 0.1)) if run else 0.0
	_phase += delta * (2.0 + gait * 8.5)
	_idle_snd += delta
	if active and _idle_snd > 11.0 and not run and action_name == "":
		_idle_snd = 0.0
		AudioManager.play_animal(definition.id)
	if definition.id == &"snake":
		_animate_snake(run)
		return
	var breath := sin(_phase) * (0.01 if not run else 0.003)
	_visual.position.y = breath
	var head := _visual.get_node_or_null("Head")
	if head:
		if action_name == "push":
			head.rotation_degrees.x = lerpf(head.rotation_degrees.x, 22.0, 0.15)
			head.rotation_degrees.y = 0.0
		elif action_name == "climb":
			head.rotation_degrees.x = -12.0
			head.rotation_degrees.y = sin(_phase * 3.0) * 8.0
		else:
			head.rotation_degrees.y = sin(_phase * 0.45) * (8.0 if not run else 3.0)
			head.rotation_degrees.x = sin(_phase * 0.3) * 3.0
	var swing := sin(_phase * 2.0) * (8.0 + gait * 20.0)
	if action_name == "climb":
		swing = sin(_phase * 4.2) * 38.0
	if action_name == "push":
		swing = sin(_phase * 3.0) * 8.0
	for nm in ["LegFL", "LegBR", "LegL", "ArmR"]:
		var n := _visual.get_node_or_null(nm)
		if n:
			n.rotation_degrees.x = swing
	for nm in ["LegFR", "LegBL", "LegR", "ArmL"]:
		var n := _visual.get_node_or_null(nm)
		if n:
			n.rotation_degrees.x = -swing
	var tail := _visual.get_node_or_null("Tail")
	if tail:
		tail.rotation_degrees.y = sin(_phase * 1.4) * (12.0 if run else 4.0)
	if _dust:
		_dust.emitting = run and active
	if run:
		_foot_t += delta
		if _foot_t > lerpf(0.42, 0.26, gait):
			_foot_t = 0.0
			if active:
				AudioManager.play_sfx("sfx_footstep")


func _animate_snake(run: bool) -> void:
	_visual.position.y = 0.0
	var segs := _visual.get_node_or_null("Segments")
	var coil := action_name == "coil"
	if segs:
		var i := 0
		for c in segs.get_children():
			if coil:
				var ang := i * 0.55 + _action_t * 7.0
				c.position = Vector3(cos(ang) * 0.26, 0.12 + i * 0.035, sin(ang) * 0.26)
				c.rotation_degrees = Vector3(90, rad_to_deg(ang), 0)
			else:
				var amp := 0.22 if run else 0.05
				var wave := sin(_phase * 2.4 + i * 0.62)
				var wave2 := sin(_phase * 2.4 + (i + 1) * 0.62)
				c.position.x = wave * amp
				c.position.y = 0.14
				c.position.z = -i * 0.2
				c.rotation_degrees.y = rad_to_deg(atan2((wave2 - wave) * amp, -0.2))
				c.rotation_degrees.x = 90.0
			i += 1
	var hd := _visual.get_node_or_null("Head")
	if hd:
		if coil:
			hd.position = Vector3(0.28, 0.22, 0.0)
			hd.rotation_degrees.y = _action_t * 120.0
		else:
			hd.position = Vector3(0, 0.16, 0.28)
			hd.rotation_degrees.y = sin(_phase * 0.9) * (16.0 if run else 5.0)
			hd.rotation_degrees.x = sin(_phase * 1.1) * (6.0 if run else 2.0)
		var tongue := hd.get_node_or_null("Tongue")
		if tongue:
			tongue.scale.z = 1.0 + abs(sin(_phase * 6.0)) * 0.9
