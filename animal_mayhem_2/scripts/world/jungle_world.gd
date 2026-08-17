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

@onready var builder: JungleBuilder = $Jungle


func _ready() -> void:
	GameState.reset()
	builder.build()
	camera = FollowCamera.new()
	add_child(camera)
	_spawn_animals()
	probe = InteractProbe.new()
	add_child(probe)
	_make_hud()
	_switch(0, true)
	GameState.objective_changed.connect(_on_objective)
	GameState.mission_completed.connect(_on_complete)
	_on_objective(GameState.objective_text())
	print("ANIMAL_MAYHEM_2_WORLD_READY animals=", animals.size())
	if OS.get_environment("AM2_SCREENSHOT") != "":
		call_deferred("_capture_screenshot")


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
	AudioManager.set_mix(water_amt, forest_amt)
	if camera.target:
		camera.distance = lerp(camera.distance, active.definition.camera_distance, 1.0 - exp(-delta * 3.0))
		camera.height = lerp(camera.height, active.definition.camera_height, 1.0 - exp(-delta * 3.0))


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
		var look_height := a.definition.camera_height * 0.52
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


func _on_complete() -> void:
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
	await get_tree().create_timer(1.2).timeout
	var img := get_viewport().get_texture().get_image()
	if img == null:
		print("ANIMAL_MAYHEM_2_SCREENSHOT_FAIL")
		return
	var path := OS.get_environment("AM2_SCREENSHOT")
	img.save_png(path)
	print("ANIMAL_MAYHEM_2_SCREENSHOT ", path)
