class_name JungleWorld
extends Node3D
## Phase 1 vertical slice orchestrator.

var move_vector := Vector2.ZERO
var camera: FollowCamera
var animals: Array[AnimalController] = []
var active_index := 0
var probe: InteractProbe
var hud: CanvasLayer
var look_dragging := false
var look_pointer := -1
var _validation_lock_follow := false
var _recovery: AnimalRecovery
var _objective_marker: ObjectiveMarker

@onready var builder: JungleBuilder = $Jungle


func _ready() -> void:
	GameState.reset()
	builder.build()
	camera = FollowCamera.new()
	add_child(camera)
	_spawn_animals()
	probe = InteractProbe.new()
	add_child(probe)
	_recovery = AnimalRecovery.new()
	_recovery.setup(builder)
	_objective_marker = ObjectiveMarker.new()
	add_child(_objective_marker)
	_make_hud()
	_switch(0, true)
	GameState.objective_changed.connect(_on_objective)
	GameState.mission_completed.connect(_on_complete)
	_on_objective(GameState.objective_text())
	print("ANIMAL_MAYHEM_2_WORLD_READY animals=", animals.size())
	if OS.get_environment("AM2_SCREENSHOT") != "":
		call_deferred("_capture_screenshot")
	if OS.get_environment("AM2_PHASE7_CHECK") != "":
		call_deferred("_phase7_contract_check")
	if OS.get_environment("AM2_PHASE8_CHECK") != "":
		call_deferred("_phase8_contract_check")


func _spawn_animals() -> void:
	var spots := [
		Vector3(-1.6, 0, 1.4),
		Vector3(1.8, 0, 0.6),
		Vector3(-0.2, 0, -1.8),
	]
	var defs := AnimalCatalog.all()
	for i in defs.size():
		var a := AnimalController.new()
		a.setup(defs[i], self)
		var p: Vector3 = spots[i]
		p.y = builder.height_at(p.x, p.z) + 0.2
		a.position = p
		add_child(a)
		animals.append(a)


func _process(delta: float) -> void:
	_read_keyboard()
	if animals.is_empty():
		return
	var active := animals[active_index]
	probe.global_position = active.global_position + Vector3(0, 0.6, 0)
	probe.scan(active)
	hud.call("set_action", probe.current != null, GameState.action_label_for(probe.current_ability))
	var d_water := active.global_position.distance_to(Vector3(26, 0, -9))
	var water_amt := clampf(1.0 - d_water / 16.0, 0.0, 1.0)
	var from_camp := Vector2(active.global_position.x, active.global_position.z).length()
	var forest_amt := clampf((from_camp - 6.0) / 22.0, 0.4, 1.0)
	if water_amt > 0.35:
		forest_amt *= 0.72
	var camp_amt := clampf(1.0 - from_camp / 9.0, 0.0, 1.0)
	AudioManager.set_mix(water_amt, forest_amt, camp_amt)
	if camera.target and not _validation_lock_follow:
		camera.distance = lerp(camera.distance, active.definition.camera_distance, 1.0 - exp(-delta * 2.4))
		camera.height = lerp(camera.height, active.definition.camera_height, 1.0 - exp(-delta * 2.4))
	if _recovery and _recovery.tick(delta, animals):
		if hud:
			hud.call("show_notice", "Returned to the trail.")


func _read_keyboard() -> void:
	if hud and hud.get("joystick_active"):
		return
	var v := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	)
	if v.length() > 0.01:
		move_vector = v.limit_length(1.0)
	elif not hud.get("joystick_active"):
		move_vector = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("action"):
		try_action()
	if event.is_action_pressed("switch_1"):
		_switch(0)
	if event.is_action_pressed("switch_2"):
		_switch(1)
	if event.is_action_pressed("switch_3"):
		_switch(2)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		look_dragging = event.pressed
	if event is InputEventMouseMotion and look_dragging:
		camera.add_look(event.relative)
	if event is InputEventScreenDrag:
		if event.position.x > get_viewport().get_visible_rect().size.x * 0.55:
			camera.add_look(event.relative)
	if OS.get_environment("AM2_SCREENSHOT") != "" and event is InputEventKey:
		if event.pressed and not event.echo and event.keycode == KEY_F7:
			_validation_goto_explorer()


func try_action() -> void:
	if probe.current == null:
		return
	var animal := animals[active_index]
	for ability in animal.abilities:
		if ability.execute(animal, probe.current):
			return
	if probe.current_ability == "narrow":
		return


func _switch(index: int, instant := false) -> void:
	if index < 0 or index >= animals.size():
		return
	active_index = index
	for i in animals.size():
		animals[i].active = i == index
	var a := animals[index]
	camera.target = a
	camera.distance = a.definition.camera_distance
	camera.height = a.definition.camera_height
	if instant:
		var look_height := a.definition.camera_height * 0.38
		camera.global_position = a.global_position + Vector3(0, look_height, 0) + Vector3(
			sin(camera.yaw) * camera.distance,
			a.definition.camera_height,
			cos(camera.yaw) * camera.distance
		)
	else:
		AudioManager.play_sfx("sfx_switch")
		AudioManager.play_animal(a.definition.id)
	if hud:
		hud.call("set_animal", index, a.definition.display_name)


func _on_objective(text: String) -> void:
	if hud:
		hud.call("set_objective", text)
	_sync_wayfinding()
	if OS.get_environment("AM2_SCREENSHOT") != "":
		print("ANIMAL_MAYHEM_2_OBJECTIVE ", text)


func _sync_wayfinding() -> void:
	if _objective_marker == null or builder == null:
		return
	var xz := Vector2.ZERO
	match GameState.step:
		GameState.Step.INTRO, GameState.Step.TREE:
			xz = Vector2(12.5, 0.0)
		GameState.Step.CLIMB:
			xz = Vector2(24.5, 12.0)
		GameState.Step.COIL:
			xz = Vector2(33.8, -8.5)
		GameState.Step.EXPLORER:
			xz = Vector2(44.5, 0.0)
		_:
			_objective_marker.hide_marker()
			return
	_objective_marker.show_at(xz, builder.height_at(xz.x, xz.y))
	if OS.get_environment("AM2_PHASE8_CHECK") != "" or OS.get_environment("AM2_SCREENSHOT") != "":
		print("ANIMAL_MAYHEM_2_WAYFIND step=", GameState.step, " xz=", xz)


func _on_complete() -> void:
	if OS.get_environment("AM2_SCREENSHOT") != "":
		print("ANIMAL_MAYHEM_2_COMPLETE")
	if hud:
		hud.call("show_complete")


func _make_hud() -> void:
	hud = load("res://scenes/ui/hud.tscn").instantiate()
	add_child(hud)
	hud.move_changed.connect(func (v: Vector2) -> void:
		move_vector = v
	)
	hud.action_pressed.connect(try_action)
	hud.animal_selected.connect(_switch)
	hud.look_moved.connect(func (rel: Vector2) -> void:
		camera.add_look(rel)
	)


func _capture_screenshot() -> void:
	var shot := OS.get_environment("AM2_SHOT").strip_edges()
	_apply_validation_shot(shot)
	await get_tree().create_timer(1.4).timeout
	var img := get_viewport().get_texture().get_image()
	if img == null:
		print("ANIMAL_MAYHEM_2_SCREENSHOT_FAIL")
		return
	var path := OS.get_environment("AM2_SCREENSHOT")
	img.save_png(path)
	print("ANIMAL_MAYHEM_2_SCREENSHOT ", path)
	get_tree().quit(0)


func _apply_validation_shot(shot: String) -> void:
	if animals.is_empty():
		return
	var animal_i := 0
	var xz := Vector2(0.0, 0.0)
	match shot:
		"A", "J", "G":
			animal_i = 0
			xz = Vector2(0.4, 1.2)
		"B":
			animal_i = 1
			xz = Vector2(1.2, 0.4)
		"C":
			animal_i = 2
			xz = Vector2(0.2, -1.2)
		"D":
			animal_i = 0
			xz = Vector2(12.5, 0.0)
		"E":
			# Stand just south of the climb volume so the monkey is readable.
			animal_i = 1
			xz = Vector2(24.5, 9.9)
		"F":
			# Landmark stays at (33.8, -8.5). Spawn beside it, outside the river
			# basin (x>=34) so physics does not eject the snake into the water.
			animal_i = 2
			xz = Vector2(35.2, -8.5)
		"H":
			animal_i = 0
			xz = Vector2(26.0, -9.0)
		"I":
			animal_i = 0
			xz = Vector2(8.0, 0.4)
		_:
			return
	_switch(animal_i, true)
	var a := animals[animal_i]
	var y := builder.height_at(xz.x, xz.y) + 0.25
	a.global_position = Vector3(xz.x, y, xz.y)
	a.velocity = Vector3.ZERO
	a.rotation.y = 1.2
	_validation_lock_follow = false
	camera.yaw = 2.55
	camera.pitch = -0.06
	if shot == "F":
		_validation_lock_follow = true
		camera.distance = 3.6
		camera.height = 1.12
		camera.yaw = 1.18
		camera.pitch = -0.05
	elif shot == "E":
		_validation_lock_follow = true
		camera.distance = 6.4
		camera.height = 2.35
		camera.yaw = 0.92
		camera.pitch = -0.08
	camera.global_position = a.global_position + Vector3(
		sin(camera.yaw) * camera.distance,
		camera.height,
		cos(camera.yaw) * camera.distance
	)
	camera.target = a


func _validation_goto_explorer() -> void:
	## Isolated validation teleport. Does not touch GameState.
	if animals.is_empty() or camera == null:
		return
	var a := animals[active_index]
	var xz := Vector2(44.5, 0.0)
	var y := builder.height_at(xz.x, xz.y) + 0.25
	a.global_position = Vector3(xz.x, y, xz.y)
	a.velocity = Vector3.ZERO
	camera.yaw = 2.2
	camera.pitch = -0.12
	camera.global_position = a.global_position + Vector3(
		sin(camera.yaw) * camera.distance,
		camera.height,
		cos(camera.yaw) * camera.distance
	)
	print("ANIMAL_MAYHEM_2_VALIDATION_EXPLORER")


func _phase7_contract_check() -> void:
	## Env-gated contract check. Does not change mission flow for players.
	if animals.size() != 3 or hud == null or camera == null:
		push_error("PHASE7_FAIL world/hud/camera")
		get_tree().quit(1)
		return
	print("PHASE7_HUD_OK")
	var snake := animals[2]
	var col: CollisionShape3D = null
	for c in snake.get_children():
		if c is CollisionShape3D:
			col = c
			break
	if col == null:
		push_error("PHASE7_FAIL snake collision missing")
		get_tree().quit(1)
		return
	var cap := col.shape as CapsuleShape3D
	if cap == null:
		push_error("PHASE7_FAIL snake shape")
		get_tree().quit(1)
		return
	print("PHASE7_SNAKE_DEF radius=", snake.definition.collision_radius, " height=", snake.definition.collision_height)
	print("PHASE7_SNAKE_SHAPE radius=", cap.radius, " height=", cap.height)
	if not is_equal_approx(snake.definition.collision_radius, 0.3) or not is_equal_approx(snake.definition.collision_height, 0.48):
		push_error("PHASE7_FAIL snake catalog capsule")
		get_tree().quit(1)
		return
	_switch(0)
	print("PHASE7_SWITCH buffalo")
	_switch(1)
	print("PHASE7_SWITCH monkey")
	_switch(2)
	print("PHASE7_SWITCH snake")
	await _phase7_teleport_and_act(0, Vector2(10.8, 0.0))
	await get_tree().create_timer(1.4).timeout
	if not GameState.tree_cleared:
		push_error("PHASE7_FAIL PUSH")
		get_tree().quit(1)
		return
	print("PHASE7_PUSH_OK")
	await _phase7_teleport_and_act(1, Vector2(24.5, 9.9))
	await get_tree().create_timer(1.5).timeout
	if not GameState.climb_done:
		push_error("PHASE7_FAIL CLIMB")
		get_tree().quit(1)
		return
	print("PHASE7_CLIMB_OK")
	await _phase7_teleport_and_act(2, Vector2(35.2, -8.5))
	await get_tree().create_timer(1.0).timeout
	if not GameState.coil_done:
		push_error("PHASE7_FAIL COIL")
		get_tree().quit(1)
		return
	print("PHASE7_COIL_OK")
	var a := animals[active_index]
	var xz := Vector2(44.5, 0.0)
	a.global_position = Vector3(xz.x, builder.height_at(xz.x, xz.y) + 0.25, xz.y)
	a.velocity = Vector3.ZERO
	await get_tree().create_timer(0.6).timeout
	if GameState.step != GameState.Step.DONE:
		push_error("PHASE7_FAIL completion")
		get_tree().quit(1)
		return
	print("PHASE7_COMPLETE_OK")
	hud._on_pause()
	if not get_tree().paused:
		push_error("PHASE7_FAIL pause")
		get_tree().quit(1)
		return
	print("PHASE7_PAUSE_OK")
	hud._on_pause()
	if get_tree().paused:
		push_error("PHASE7_FAIL resume")
		get_tree().quit(1)
		return
	print("PHASE7_RESUME_OK")
	print("PHASE7_ALL_OK")
	get_tree().quit(0)


func _phase7_teleport_and_act(idx: int, xz: Vector2) -> void:
	_switch(idx, true)
	var a := animals[idx]
	a.global_position = Vector3(xz.x, builder.height_at(xz.x, xz.y) + 0.25, xz.y)
	a.velocity = Vector3.ZERO
	probe.monitoring = true
	probe.global_position = a.global_position + Vector3(0, 0.6, 0)
	for _i in 30:
		await get_tree().physics_frame
	probe.global_position = a.global_position + Vector3(0, 0.6, 0)
	probe.scan(a)
	print("PHASE7_PROBE ability=", probe.current_ability, " current=", probe.current)
	if probe.current == null:
		var target := _phase7_find_target(idx)
		if target:
			print("PHASE7_PROBE_FALLBACK ", target)
			for ability in a.abilities:
				if ability.execute(a, target):
					break
	else:
		try_action()
	await get_tree().process_frame


func _phase7_find_target(idx: int) -> Node3D:
	for n in builder.get_children():
		if idx == 0 and n is FallenTree:
			return n
		if idx == 1 and n is ClimbLedge:
			return n
		if idx == 2 and n is CoilPost:
			return n
	return null


func _phase8_contract_check() -> void:
	## Env-gated Phase 8 HUD / wayfinding / recovery check. Does not change player flow.
	if animals.size() != 3 or hud == null or camera == null or _recovery == null or _objective_marker == null:
		push_error("PHASE8_FAIL world/hud/marker/recovery")
		get_tree().quit(1)
		return
	await get_tree().process_frame
	await get_tree().process_frame
	print("PHASE8_HUD_OK")
	if InputMap.has_action("jump"):
		push_error("PHASE8_FAIL jump input must not exist")
		get_tree().quit(1)
		return
	print("PHASE8_NO_JUMP_OK")
	var card: Control = hud.get_node("Root/ObjectiveCard")
	var pause_btn: Control = hud.get_node("Root/Pause")
	var act: Control = hud.get_node("Root/ActionButton")
	var stick_c: Control = hud.get_node("Root/Joystick")
	var p0: Control = hud.get_node("Root/Portraits/B0")
	if card.size.x < 500.0 or card.size.y < 110.0:
		push_error("PHASE8_FAIL objective size %s" % card.size)
		get_tree().quit(1)
		return
	if pause_btn.custom_minimum_size.x < 70.0 or pause_btn.custom_minimum_size.y < 70.0:
		push_error("PHASE8_FAIL pause size")
		get_tree().quit(1)
		return
	if act.custom_minimum_size.x < 118.0 or act.custom_minimum_size.y < 118.0:
		push_error("PHASE8_FAIL action size")
		get_tree().quit(1)
		return
	if stick_c.size.x < 160.0 or stick_c.size.y < 160.0:
		push_error("PHASE8_FAIL joystick size %s" % stick_c.size)
		get_tree().quit(1)
		return
	if p0.custom_minimum_size.x < 130.0 or p0.custom_minimum_size.y < 52.0:
		push_error("PHASE8_FAIL portrait size")
		get_tree().quit(1)
		return
	print("PHASE8_HUD_SIZES_OK card=", card.size, " pause=", pause_btn.size, " action=", act.custom_minimum_size)
	_switch(0)
	print("PHASE8_SWITCH buffalo")
	_switch(1)
	print("PHASE8_SWITCH monkey")
	_switch(2)
	print("PHASE8_SWITCH snake")
	_switch(0, true)
	if not _marker_near(Vector2(12.5, 0.0)):
		push_error("PHASE8_FAIL wayfind tree")
		get_tree().quit(1)
		return
	print("PHASE8_WAYFIND_TREE_OK")
	var step0: GameState.Step = GameState.step
	var tree0 := GameState.tree_cleared
	var climb0 := GameState.climb_done
	var coil0 := GameState.coil_done
	var buffalo := animals[0]
	var layer0 := buffalo.collision_layer
	var mask0 := buffalo.collision_mask
	var ability_n := buffalo.abilities.size()
	buffalo.global_position = Vector3(0.0, -6.0, 0.0)
	buffalo.velocity = Vector3(0, -8, 0)
	await _wait_sec(0.45)
	if buffalo.global_position.y < -1.0:
		push_error("PHASE8_FAIL fall recover y=%s" % buffalo.global_position.y)
		get_tree().quit(1)
		return
	if GameState.step != step0 or GameState.tree_cleared != tree0 or GameState.climb_done != climb0 or GameState.coil_done != coil0:
		push_error("PHASE8_FAIL recover mutated GameState")
		get_tree().quit(1)
		return
	if buffalo.collision_layer != layer0 or buffalo.collision_mask != mask0 or buffalo.abilities.size() != ability_n:
		push_error("PHASE8_FAIL recover mutated collision/abilities")
		get_tree().quit(1)
		return
	print("PHASE8_FALL_RECOVER_OK pad=", buffalo.global_position)
	buffalo.global_position = Vector3(26.0, builder.height_at(26.0, -9.0) + 0.2, -9.0)
	buffalo.velocity = Vector3.ZERO
	await _wait_sec(0.85)
	var bxz := Vector2(buffalo.global_position.x, buffalo.global_position.z)
	if bxz.x > 18.0 and bxz.x < 34.0 and bxz.y > -14.0 and bxz.y < -4.0:
		push_error("PHASE8_FAIL river recover still in basin %s" % bxz)
		get_tree().quit(1)
		return
	if GameState.tree_cleared:
		push_error("PHASE8_FAIL river recover cleared tree")
		get_tree().quit(1)
		return
	print("PHASE8_RIVER_RECOVER_OK pos=", buffalo.global_position)
	var monkey := animals[1]
	monkey.global_position = Vector3(8.0, builder.height_at(8.0, 0.0) - 4.0, 0.0)
	monkey.velocity = Vector3.ZERO
	await _wait_sec(0.55)
	if monkey.global_position.y < builder.height_at(monkey.global_position.x, monkey.global_position.z) - 1.0:
		push_error("PHASE8_FAIL monkey below-terrain recover")
		get_tree().quit(1)
		return
	print("PHASE8_MONKEY_RECOVER_OK")
	var snake := animals[2]
	var coil_pos := Vector3(35.2, builder.height_at(35.2, -8.5) + 0.2, -8.5)
	snake.global_position = coil_pos
	snake.velocity = Vector3.ZERO
	var recovers_before := _recovery.recover_count
	await _wait_sec(0.9)
	var sdist := Vector2(snake.global_position.x, snake.global_position.z).distance_to(Vector2(35.2, -8.5))
	if sdist > 1.6:
		push_error("PHASE8_FAIL snake coil exclusion moved to %s" % snake.global_position)
		get_tree().quit(1)
		return
	if _recovery.recover_count != recovers_before:
		push_error("PHASE8_FAIL snake coil was recovered")
		get_tree().quit(1)
		return
	print("PHASE8_SNAKE_COIL_EXCLUSION_OK")
	snake.global_position = Vector3(22.0, builder.height_at(22.0, -10.0) + 0.2, -10.0)
	snake.velocity = Vector3.ZERO
	await _wait_sec(0.85)
	var snxz := Vector2(snake.global_position.x, snake.global_position.z)
	if snxz.x > 18.0 and snxz.x < 34.0 and snxz.y > -14.0 and snxz.y < -4.0:
		if snxz.distance_to(Vector2(31.5, -7.0)) > 3.0 and snxz.distance_to(Vector2(33.8, -8.5)) > 3.0:
			push_error("PHASE8_FAIL snake river recover still in basin %s" % snxz)
			get_tree().quit(1)
			return
	print("PHASE8_SNAKE_RIVER_RECOVER_OK pos=", snake.global_position)
	snake.global_position = Vector3(-0.2, -6.0, -1.8)
	snake.velocity = Vector3.ZERO
	await _wait_sec(0.45)
	if snake.global_position.y < -1.0:
		push_error("PHASE8_FAIL snake fall recover")
		get_tree().quit(1)
		return
	print("PHASE8_SNAKE_FALL_RECOVER_OK pos=", snake.global_position)
	await _phase7_teleport_and_act(0, Vector2(10.8, 0.0))
	await get_tree().create_timer(1.4).timeout
	if not GameState.tree_cleared:
		push_error("PHASE8_FAIL PUSH")
		get_tree().quit(1)
		return
	print("PHASE8_PUSH_OK")
	if not _marker_near(Vector2(24.5, 12.0)):
		push_error("PHASE8_FAIL wayfind climb")
		get_tree().quit(1)
		return
	print("PHASE8_WAYFIND_CLIMB_OK")
	await _phase7_teleport_and_act(1, Vector2(24.5, 9.9))
	await get_tree().create_timer(1.5).timeout
	if not GameState.climb_done:
		push_error("PHASE8_FAIL CLIMB")
		get_tree().quit(1)
		return
	print("PHASE8_CLIMB_OK")
	if not _marker_near(Vector2(33.8, -8.5)):
		push_error("PHASE8_FAIL wayfind coil")
		get_tree().quit(1)
		return
	print("PHASE8_WAYFIND_COIL_OK")
	snake.global_position = Vector3(35.2, builder.height_at(35.2, -8.5) + 0.2, -8.5)
	snake.velocity = Vector3.ZERO
	recovers_before = _recovery.recover_count
	await _wait_sec(0.8)
	if _recovery.recover_count != recovers_before:
		push_error("PHASE8_FAIL snake recovered during COIL step")
		get_tree().quit(1)
		return
	print("PHASE8_SNAKE_COIL_STEP_EXCLUSION_OK")
	await _phase7_teleport_and_act(2, Vector2(35.2, -8.5))
	await get_tree().create_timer(1.0).timeout
	if not GameState.coil_done:
		push_error("PHASE8_FAIL COIL")
		get_tree().quit(1)
		return
	print("PHASE8_COIL_OK")
	if not _marker_near(Vector2(44.5, 0.0)):
		push_error("PHASE8_FAIL wayfind explorer")
		get_tree().quit(1)
		return
	print("PHASE8_WAYFIND_EXPLORER_OK")
	var a := animals[active_index]
	var xz := Vector2(44.5, 0.0)
	a.global_position = Vector3(xz.x, builder.height_at(xz.x, xz.y) + 0.25, xz.y)
	a.velocity = Vector3.ZERO
	await get_tree().create_timer(0.6).timeout
	if GameState.step != GameState.Step.DONE:
		push_error("PHASE8_FAIL completion")
		get_tree().quit(1)
		return
	print("PHASE8_COMPLETE_OK")
	hud._on_pause()
	if not get_tree().paused:
		push_error("PHASE8_FAIL pause")
		get_tree().quit(1)
		return
	print("PHASE8_PAUSE_OK")
	hud._on_pause()
	if get_tree().paused:
		push_error("PHASE8_FAIL resume")
		get_tree().quit(1)
		return
	print("PHASE8_RESUME_OK")
	print("PHASE8_ALL_OK")
	get_tree().quit(0)


func _marker_near(xz: Vector2) -> bool:
	if _objective_marker == null or not _objective_marker.visible:
		return false
	var p := _objective_marker.global_position
	return Vector2(p.x, p.z).distance_to(xz) < 0.35


func _wait_sec(sec: float) -> void:
	var end := Time.get_ticks_msec() + int(sec * 1000.0)
	while Time.get_ticks_msec() < end:
		await get_tree().process_frame

