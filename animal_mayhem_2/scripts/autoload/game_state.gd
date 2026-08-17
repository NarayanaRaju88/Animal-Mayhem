extends Node
## Phase 1 mission progress. Local only; no accounts or cloud.

signal objective_changed(text: String)
signal mission_completed

enum Step { INTRO, TREE, CLIMB, COIL, EXPLORER, DONE }

var step: Step = Step.INTRO
var tree_cleared := false
var climb_done := false
var coil_done := false
var mission_name := "The Lost Explorer"


func reset() -> void:
	step = Step.INTRO
	tree_cleared = false
	climb_done = false
	coil_done = false
	objective_changed.emit(objective_text())


func mark_tree_cleared() -> void:
	tree_cleared = true
	step = Step.CLIMB
	objective_changed.emit(objective_text())


func mark_climb_done() -> void:
	climb_done = true
	step = Step.COIL
	objective_changed.emit(objective_text())


func mark_coil_done() -> void:
	coil_done = true
	step = Step.EXPLORER
	objective_changed.emit(objective_text())


func mark_complete() -> void:
	if step == Step.DONE:
		return
	step = Step.DONE
	objective_changed.emit("Mission complete")
	mission_completed.emit()
	AudioManager.play_sfx("sfx_complete")


func objective_text() -> String:
	match step:
		Step.INTRO, Step.TREE:
			return "Find a way through the blocked jungle path"
		Step.CLIMB:
			return "Reach the high rocks — the monkey can climb"
		Step.COIL:
			return "Use the snake to enter the gap and coil the post"
		Step.EXPLORER:
			return "Follow the open trail to the missing explorer"
		Step.DONE:
			return "Mission complete"
	return ""


func action_label_for(ability: String) -> String:
	match ability:
		"force":
			return "PUSH"
		"climb":
			return "CLIMB"
		"coil":
			return "COIL"
		_:
			return "USE"
