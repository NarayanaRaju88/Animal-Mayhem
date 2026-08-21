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
	var breath := sin(_phase * 0.85) * (0.012 if not run else 0.003)
	_visual.position.y = 0.0
	var body := _visual.get_node_or_null("Body")
	if body:
		body.scale = Vector3(1.0 + breath * 0.35, 1.0 + breath, 1.0 + breath * 0.2)
	var weight := sin(_phase * 0.55) * (1.8 if not run else 0.0)
	if run:
		_visual.rotation_degrees.z = sin(_phase * 2.0) * 2.1
		_visual.rotation_degrees.x = sin(_phase * 2.0) * 1.6
	else:
		_visual.rotation_degrees.z = lerpf(_visual.rotation_degrees.z, weight, 0.08)
		_visual.rotation_degrees.x = lerpf(_visual.rotation_degrees.x, 0.0, 0.1)
	if action_name == "push":
		_visual.rotation_degrees.x = lerpf(_visual.rotation_degrees.x, 10.0, 0.12)
	var head := _visual.get_node_or_null("Head")
	if head:
		if action_name == "push":
			head.rotation_degrees.x = lerpf(head.rotation_degrees.x, 26.0, 0.16)
			head.rotation_degrees.y = 0.0
		elif action_name == "climb":
			head.rotation_degrees.x = -12.0
			head.rotation_degrees.y = sin(_phase * 3.0) * 8.0
		else:
			head.rotation_degrees.y = sin(_phase * 0.45) * (10.0 if not run else 3.5)
			head.rotation_degrees.x = sin(_phase * 0.3) * (4.0 if not run else 2.0)
		var ear_l := head.get_node_or_null("EarL")
		var ear_r := head.get_node_or_null("EarR")
		if ear_l:
			ear_l.rotation_degrees.z = sin(_phase * 1.7) * (8.0 if not run else 3.0)
		if ear_r:
			ear_r.rotation_degrees.z = sin(_phase * 1.7 + 0.8) * (8.0 if not run else 3.0)
	var swing := sin(_phase * 2.0) * (9.0 + gait * 22.0)
	if action_name == "climb":
		swing = sin(_phase * 4.2) * 38.0
	if action_name == "push":
		swing = sin(_phase * 2.4) * 5.0
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
		tail.rotation_degrees.y = sin(_phase * 1.4) * (14.0 if run else 5.0)
		tail.rotation_degrees.x = sin(_phase * 0.9) * 4.0
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
	var spacing := 0.175
	if segs:
		var i := 0
		var count := segs.get_child_count()
		for c in segs.get_children():
			if coil:
				var ang := i * (TAU / maxf(float(count), 1.0)) + _action_t * 4.2
				var rad := 0.22 + i * 0.012
				c.position = Vector3(cos(ang) * rad, 0.055 + i * 0.018, sin(ang) * rad)
			else:
				var amp := 0.22 if run else 0.09
				var lag := float(i) * 0.52
				var wave := sin(_phase * 2.8 - lag)
				c.position.x = wave * amp * (1.0 - float(i) / 26.0)
				c.position.y = 0.055 + absf(wave) * 0.016
				c.position.z = -float(i) * spacing
			i += 1
	var hd := _visual.get_node_or_null("Head")
	if hd:
		if coil:
			hd.position = Vector3(0.32, 0.16, 0.04)
			hd.rotation_degrees.y = _action_t * 90.0
			hd.rotation_degrees.x = -8.0
		else:
			var lead := sin(_phase * 2.6) * (0.16 if run else 0.04)
			hd.position = Vector3(lead, 0.1, 0.26)
			hd.rotation_degrees.y = sin(_phase * 0.9) * (18.0 if run else 6.0)
			hd.rotation_degrees.x = sin(_phase * 1.1) * (5.0 if run else 2.0)
		var tongue := hd.get_node_or_null("Tongue")
		if tongue:
			tongue.scale.z = 1.0 + abs(sin(_phase * 6.0)) * 0.9
	var body := _visual.get_node_or_null("BodyMesh")
	if body and segs:
		var pts := PackedVector3Array()
		pts.append(hd.position if hd else Vector3(0, 0.1, 0.26))
		for c in segs.get_children():
			pts.append((c as Node3D).position)
		SnakeTube.rebuild(body as MeshInstance3D, pts, body.material_override)
