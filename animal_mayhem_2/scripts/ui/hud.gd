extends CanvasLayer

signal move_changed(value: Vector2)
signal action_pressed
signal animal_selected(index: int)
signal look_moved(relative: Vector2)

var joystick_active := false

@onready var objective: Label = $Root/TopBar/Objective
@onready var animal_name: Label = $Root/TopBar/AnimalName
@onready var action_btn: Button = $Root/ActionButton
@onready var stick: Control = $Root/Joystick
@onready var stick_knob: Control = $Root/Joystick/Knob
@onready var portraits: HBoxContainer = $Root/Portraits


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	action_btn.visible = false
	action_btn.pressed.connect(func () -> void: action_pressed.emit())
	$Root/TopBar/Pause.pressed.connect(_on_pause)
	$Root/Joystick.gui_input.connect(_gui_stick)
	$Complete/Panel/VBox/Continue.pressed.connect(_on_continue)
	for i in portraits.get_child_count():
		var b: Button = portraits.get_child(i)
		var idx := i
		b.pressed.connect(func () -> void: animal_selected.emit(idx))


func set_objective(text: String) -> void:
	objective.text = text


func set_animal(index: int, display: String) -> void:
	animal_name.text = display
	for i in portraits.get_child_count():
		var b: Button = portraits.get_child(i)
		b.modulate = Color(1.15, 1.12, 0.9) if i == index else Color(0.75, 0.8, 0.75)
		b.scale = Vector2(1.08, 1.08) if i == index else Vector2.ONE


func set_action(show: bool, label: String) -> void:
	action_btn.visible = show
	action_btn.text = label


func show_complete() -> void:
	$Complete.visible = true


func _on_pause() -> void:
	get_tree().paused = not get_tree().paused
	$Root/TopBar/Pause.text = "Resume" if get_tree().paused else "II"


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
