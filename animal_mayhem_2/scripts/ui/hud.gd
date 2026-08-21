extends CanvasLayer

signal move_changed(value: Vector2)
signal action_pressed
signal animal_selected(index: int)
signal look_moved(relative: Vector2)

const _INK := Color(0.94, 0.91, 0.82, 0.96)
const _INK_DIM := Color(0.78, 0.74, 0.58, 0.88)
const _INK_MUTED := Color(0.70, 0.72, 0.64, 0.88)
const _PANEL := Color(0.07, 0.10, 0.08, 0.78)
const _PANEL_SOFT := Color(0.08, 0.11, 0.09, 0.62)
const _LINE := Color(0.78, 0.70, 0.42, 0.42)
const _GOLD := Color(0.90, 0.80, 0.48, 0.92)
const _ANIMAL_NAMES := ["Buffalo", "Monkey", "Snake"]
const _ANIMAL_ACCENT := [
	Color(0.76, 0.62, 0.34, 0.95),
	Color(0.68, 0.50, 0.30, 0.95),
	Color(0.44, 0.60, 0.36, 0.95),
]

var joystick_active := false
var _intro_t := 0.0

@onready var objective: Label = $Root/ObjectiveCard/VBox/Objective
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
	var keep_ticking := false
	if has_node("Root/Intro"):
		var intro: Control = $Root/Intro
		if intro.visible:
			keep_ticking = true
			if _intro_t < 3.6:
				intro.modulate.a = 1.0
			else:
				intro.modulate.a = maxf(0.0, intro.modulate.a - delta * 0.8)
				if intro.modulate.a <= 0.02:
					intro.visible = false
	if has_node("Root/LookHint"):
		var hint: Control = $Root/LookHint
		if hint.visible:
			keep_ticking = true
			if _intro_t > 6.0:
				hint.modulate.a = maxf(0.0, hint.modulate.a - delta * 0.5)
				if hint.modulate.a <= 0.02:
					hint.visible = false
	if not keep_ticking:
		set_process(false)


func _style_controls() -> void:
	var panel := _flat(_PANEL, _LINE, 1, 12, 12)
	panel.content_margin_top = 10
	panel.content_margin_bottom = 10
	panel.border_width_left = 3
	panel.border_color = Color(0.82, 0.72, 0.40, 0.70)
	panel.shadow_size = 4
	panel.shadow_offset = Vector2(0, 1)
	panel.shadow_color = Color(0.02, 0.03, 0.02, 0.30)
	if has_node("Root/ObjectiveCard"):
		$Root/ObjectiveCard.add_theme_stylebox_override("panel", panel)
		$Root/ObjectiveCard.modulate = Color(1, 1, 1, 1)
	if has_node("Root/ObjectiveCard/VBox/MissionId"):
		var mid: Label = $Root/ObjectiveCard/VBox/MissionId
		mid.add_theme_color_override("font_color", _INK_DIM)
		mid.add_theme_font_size_override("font_size", 12)
		_outline(mid, 1)
	objective.add_theme_color_override("font_color", _INK)
	objective.add_theme_font_size_override("font_size", 16)
	_outline(objective, 1)

	animal_name.add_theme_color_override("font_color", _GOLD)
	animal_name.add_theme_font_size_override("font_size", 14)
	_outline(animal_name, 1)
	var name_chip := _flat(Color(0.06, 0.09, 0.07, 0.55), Color(0.78, 0.70, 0.42, 0.28), 1, 8, 8)
	name_chip.content_margin_top = 4
	name_chip.content_margin_bottom = 4
	animal_name.add_theme_stylebox_override("normal", name_chip)

	var ring := _flat(Color(0.08, 0.12, 0.09, 0.28), Color(0.82, 0.78, 0.58, 0.38), 2, 90, 0)
	$Root/Joystick/Ring.add_theme_stylebox_override("panel", ring)
	var knob := _flat(Color(0.90, 0.86, 0.68, 0.70), Color(0.96, 0.92, 0.78, 0.35), 1, 40, 0)
	$Root/Joystick/Knob.add_theme_stylebox_override("panel", knob)

	var act := _flat(Color(0.14, 0.18, 0.11, 0.82), _GOLD, 2, 56, 8)
	var act_press := _flat(Color(0.20, 0.24, 0.14, 0.90), Color(0.96, 0.88, 0.55, 1.0), 2, 56, 8)
	action_btn.add_theme_stylebox_override("normal", act)
	action_btn.add_theme_stylebox_override("hover", act_press)
	action_btn.add_theme_stylebox_override("pressed", act_press)
	action_btn.add_theme_stylebox_override("focus", act)
	action_btn.add_theme_color_override("font_color", _INK)
	action_btn.add_theme_font_size_override("font_size", 15)

	var pause := _flat(_PANEL_SOFT, _LINE, 1, 10, 8)
	var pause_press := _flat(Color(0.12, 0.16, 0.12, 0.82), _GOLD, 1, 10, 8)
	$Root/Pause.add_theme_stylebox_override("normal", pause)
	$Root/Pause.add_theme_stylebox_override("hover", pause_press)
	$Root/Pause.add_theme_stylebox_override("pressed", pause_press)
	$Root/Pause.add_theme_stylebox_override("focus", pause)
	$Root/Pause.add_theme_color_override("font_color", _INK)
	$Root/Pause.add_theme_font_size_override("font_size", 14)

	if has_node("Root/Intro"):
		var intro_box := _flat(Color(0.05, 0.08, 0.06, 0.72), Color(0.78, 0.70, 0.42, 0.35), 1, 12, 12)
		$Root/Intro.add_theme_stylebox_override("panel", intro_box)
	if has_node("Root/LookHint"):
		_outline($Root/LookHint, 1)

	var complete := _flat(Color(0.08, 0.11, 0.08, 0.92), Color(0.80, 0.72, 0.42, 0.50), 1, 14, 22)
	complete.shadow_size = 8
	complete.shadow_color = Color(0.01, 0.02, 0.01, 0.40)
	$Complete/Panel.add_theme_stylebox_override("panel", complete)
	var cont := _flat(Color(0.16, 0.20, 0.12, 0.90), _GOLD, 1, 10, 10)
	var cont_press := _flat(Color(0.22, 0.26, 0.14, 0.95), Color(0.96, 0.88, 0.55, 1.0), 1, 10, 10)
	var continue_btn: Button = $Complete/Panel/VBox/Continue
	continue_btn.add_theme_stylebox_override("normal", cont)
	continue_btn.add_theme_stylebox_override("hover", cont_press)
	continue_btn.add_theme_stylebox_override("pressed", cont_press)
	continue_btn.add_theme_color_override("font_color", _INK)
	if has_node("Complete/Panel/VBox/Title"):
		var title: Label = $Complete/Panel/VBox/Title
		title.add_theme_color_override("font_color", _INK)
		title.add_theme_font_size_override("font_size", 26)
		_outline(title, 1)
	if has_node("Complete/Panel/VBox/Name"):
		$Complete/Panel/VBox/Name.add_theme_color_override("font_color", _GOLD)
	if has_node("Complete/Panel/VBox/Status"):
		$Complete/Panel/VBox/Status.add_theme_color_override("font_color", _INK_MUTED)

	_style_portraits(-1)


func set_objective(text: String) -> void:
	objective.text = text


func set_animal(index: int, display: String) -> void:
	animal_name.text = display
	_style_portraits(index)


func _style_portraits(index: int) -> void:
	for i in portraits.get_child_count():
		var b: Button = portraits.get_child(i)
		var on := i == index
		var accent: Color = _ANIMAL_ACCENT[i] if i < _ANIMAL_ACCENT.size() else _LINE
		var box := _flat(
			Color(0.16, 0.18, 0.11, 0.88) if on else Color(0.07, 0.09, 0.07, 0.58),
			Color(0.92, 0.84, 0.50, 0.95) if on else Color(0.50, 0.54, 0.44, 0.40),
			2 if on else 1,
			10,
			8
		)
		box.border_width_left = 5
		if not on:
			box.border_color = accent
		var hover := box.duplicate() as StyleBoxFlat
		hover.bg_color = Color(0.18, 0.20, 0.13, 0.90) if on else Color(0.11, 0.13, 0.10, 0.70)
		b.add_theme_stylebox_override("normal", box)
		b.add_theme_stylebox_override("pressed", hover)
		b.add_theme_stylebox_override("hover", hover)
		b.add_theme_stylebox_override("focus", box)
		b.add_theme_color_override("font_color", Color(0.96, 0.92, 0.80, 1.0) if on else _INK_MUTED)
		b.add_theme_font_size_override("font_size", 14)
		b.scale = Vector2.ONE
		var label: String = _ANIMAL_NAMES[i] if i < _ANIMAL_NAMES.size() else b.text
		b.text = ("● " + label) if on else label


func set_action(show: bool, label: String) -> void:
	action_btn.visible = show
	action_btn.text = label


func show_complete() -> void:
	$Complete.visible = true


func _on_pause() -> void:
	get_tree().paused = not get_tree().paused
	var pause_btn: Button = $Root/Pause
	if get_tree().paused:
		pause_btn.text = "Resume"
		pause_btn.offset_left = -116.0
	else:
		pause_btn.text = "II"
		pause_btn.offset_left = -76.0


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


func _flat(bg: Color, border: Color, bw: int, radius: int, pad: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	s.set_border_width_all(bw)
	s.border_color = border
	s.set_content_margin_all(pad)
	return s


func _outline(label: Label, size: int) -> void:
	label.add_theme_constant_override("outline_size", size)
	label.add_theme_color_override("font_outline_color", Color(0.04, 0.06, 0.04, 0.72))
