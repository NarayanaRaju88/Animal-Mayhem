extends CanvasLayer

signal move_changed(value: Vector2)
signal action_pressed
signal animal_selected(index: int)
signal look_moved(relative: Vector2)

var joystick_active := false
var _intro_t := 0.0

@onready var objective: Label = $Root/ObjectiveCard/Objective
@onready var animal_name: Label = $Root/AnimalName
@onready var action_btn: Button = $Root/ActionButton
@onready var stick: Control = $Root/Joystick
@onready var stick_knob: Control = $Root/Joystick/Knob
@onready var portraits: HBoxContainer = $Root/Portraits


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	action_btn.visible = false
	action_btn.pressed.connect(func () -> void: action_pressed.emit())
	$Root/Pause.pressed.connect(_on_pause)
	$Root/Joystick.gui_input.connect(_gui_stick)
	$Complete/Panel/VBox/Continue.pressed.connect(_on_continue)
	for i in portraits.get_child_count():
		var b: Button = portraits.get_child(i)
		var idx := i
		b.pressed.connect(func () -> void: animal_selected.emit(idx))
	_style_controls()


func _process(delta: float) -> void:
	_intro_t += delta
	if has_node("Root/Intro"):
		var intro: Control = $Root/Intro
		if _intro_t < 3.6:
			intro.modulate.a = 1.0
		else:
			intro.modulate.a = maxf(0.0, intro.modulate.a - delta * 0.8)
			if intro.modulate.a <= 0.02:
				intro.visible = false
	if has_node("Root/LookHint") and _intro_t > 6.0:
		$Root/LookHint.modulate.a = maxf(0.0, $Root/LookHint.modulate.a - delta * 0.5)


func _style_controls() -> void:
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.07, 0.1, 0.08, 0.42)
	panel.set_corner_radius_all(18)
	panel.set_content_margin_all(8)
	if has_node("Root/ObjectiveCard"):
		$Root/ObjectiveCard.add_theme_stylebox_override("panel", panel)
	var ring := StyleBoxFlat.new()
	ring.bg_color = Color(0.08, 0.12, 0.09, 0.28)
	ring.set_border_width_all(2)
	ring.border_color = Color(0.85, 0.82, 0.62, 0.35)
	ring.set_corner_radius_all(90)
	$Root/Joystick/Ring.add_theme_stylebox_override("panel", ring)
	var knob := StyleBoxFlat.new()
	knob.bg_color = Color(0.92, 0.88, 0.7, 0.55)
	knob.set_corner_radius_all(40)
	$Root/Joystick/Knob.add_theme_stylebox_override("panel", knob)
	var act := StyleBoxFlat.new()
	act.bg_color = Color(0.18, 0.22, 0.14, 0.72)
	act.set_corner_radius_all(64)
	act.set_border_width_all(2)
	act.border_color = Color(0.9, 0.82, 0.45, 0.7)
	action_btn.add_theme_stylebox_override("normal", act)


func set_objective(text: String) -> void:
	objective.text = text


func set_animal(index: int, display: String) -> void:
	animal_name.text = display
	for i in portraits.get_child_count():
		var b: Button = portraits.get_child(i)
		b.modulate = Color(1.2, 1.14, 0.86) if i == index else Color(0.55, 0.6, 0.52, 0.7)
		b.scale = Vector2(1.04, 1.04) if i == index else Vector2(0.96, 0.96)


func set_action(show: bool, label: String) -> void:
	action_btn.visible = show
	action_btn.text = label


func show_complete() -> void:
	$Complete.visible = true


func _on_pause() -> void:
	get_tree().paused = not get_tree().paused
	$Root/Pause.text = "Resume" if get_tree().paused else "II"


func _on_continue() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _gui_stick(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		joystick_active = event.pressed
		if not event.pressed:
			_set_knob(Vector2.ZERO)
			move_changed.emit(Vector2.ZERO)
	if event is InputEventScreenDrag or (event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		var local: Vector2 = stick.get_local_mouse_position() - stick.size * 0.5
		var v := local / (stick.size.x * 0.42)
		if v.length() > 1.0:
			v = v.normalized()
		joystick_active = true
		_set_knob(v)
		move_changed.emit(v)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		joystick_active = event.pressed
		if event.pressed:
			var local: Vector2 = stick.get_local_mouse_position() - stick.size * 0.5
			var v := local / (stick.size.x * 0.42)
			if v.length() > 1.0:
				v = v.normalized()
			_set_knob(v)
			move_changed.emit(v)
		else:
			_set_knob(Vector2.ZERO)
			move_changed.emit(Vector2.ZERO)


func _set_knob(v: Vector2) -> void:
	stick_knob.position = stick.size * 0.5 + v * (stick.size.x * 0.32) - stick_knob.size * 0.5
