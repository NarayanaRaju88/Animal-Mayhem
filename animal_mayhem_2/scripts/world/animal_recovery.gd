class_name AnimalRecovery
extends RefCounted
## Centralized fall / water / stuck recovery for the three mission animals.
## Never advances GameState. Never changes collision layers, abilities, or selection.

const FALL_Y := -4.0
const BELOW_TERRAIN := 2.2
const EXCLUSION_M := 3.0
const RIVER_X_MIN := 18.0
const RIVER_X_MAX := 34.0
const RIVER_Z_MIN := -14.0
const RIVER_Z_MAX := -4.0

const GAP_XZ := Vector2(31.5, -7.0)
const COIL_XZ := Vector2(33.8, -8.5)
const TREE_XZ := Vector2(12.5, 0.0)
const CLIMB_XZ := Vector2(24.5, 12.0)
const EXPLORER_XZ := Vector2(44.5, 0.0)

const CAMP_BUFFALO := Vector2(-1.6, 1.4)
const CAMP_MONKEY := Vector2(1.8, 0.6)
const CAMP_SNAKE := Vector2(-0.2, -1.8)
const PAD_POST_TREE := Vector2(14.0, 0.0)
const PAD_CLIMB := Vector2(24.5, 9.9)
const PAD_COIL := Vector2(35.2, -8.5)
const PAD_EXPLORER := Vector2(42.0, 0.0)

const FALL_HOLD := 0.12
const RIVER_HOLD := 0.55
const BELOW_HOLD := 0.28
const AIR_HOLD := 2.0
const STUCK_HOLD := 3.0

var recover_count := 0
var last_reason := ""
var last_animal_id := &""
var last_pad := Vector2.ZERO

var _builder: JungleBuilder
var _air_t: Array[float] = [0.0, 0.0, 0.0]
var _fall_t: Array[float] = [0.0, 0.0, 0.0]
var _river_t: Array[float] = [0.0, 0.0, 0.0]
var _below_t: Array[float] = [0.0, 0.0, 0.0]
var _stuck_t: Array[float] = [0.0, 0.0, 0.0]


func setup(builder: JungleBuilder) -> void:
	_builder = builder


func tick(delta: float, animals: Array[AnimalController]) -> bool:
	if _builder == null or animals.is_empty():
		return false
	var any := false
	for i in animals.size():
		if _tick_one(delta, animals[i], i):
			any = true
	return any


func _tick_one(delta: float, animal: AnimalController, i: int) -> bool:
	if animal == null or animal.definition == null:
		return false
	_ensure_index(i)
	var pos := animal.global_position
	var xz := Vector2(pos.x, pos.z)
	var terrain_y := _builder.height_at(pos.x, pos.z)
	var acting := animal.action_name != ""
	if acting:
		_reset_timers(i)
		return false
	var protected := _snake_puzzle_ok(animal, xz)

	if pos.y < FALL_Y:
		_fall_t[i] += delta
	else:
		_fall_t[i] = 0.0

	if pos.y < terrain_y - BELOW_TERRAIN:
		_below_t[i] += delta
	else:
		_below_t[i] = 0.0

	if _in_river(xz) and not protected:
		_river_t[i] += delta
	else:
		_river_t[i] = 0.0

	var airborne := not animal.is_on_floor()
	if airborne and not (protected and pos.y > terrain_y - 0.5):
		_air_t[i] += delta
	else:
		_air_t[i] = 0.0

	var trying := false
	if animal.active and animal.session != null:
		trying = animal.session.move_vector.length() > 0.45
	var horiz := Vector2(animal.velocity.x, animal.velocity.z).length()
	if (
			trying
			and animal.is_on_floor()
			and horiz < 0.16
			and not protected
			and not _near_landmark(xz)
	):
		_stuck_t[i] += delta
	else:
		_stuck_t[i] = 0.0

	var reason := ""
	if _fall_t[i] >= FALL_HOLD:
		reason = "fall"
	elif _below_t[i] >= BELOW_HOLD:
		reason = "below_terrain"
	elif _river_t[i] >= RIVER_HOLD:
		reason = "river"
	elif _air_t[i] >= AIR_HOLD:
		reason = "air"
	elif _stuck_t[i] >= STUCK_HOLD:
		reason = "stuck"
	if reason == "":
		return false
	_restore(animal, xz, reason)
	_reset_timers(i)
	return true


func _restore(animal: AnimalController, from_xz: Vector2, reason: String) -> void:
	var pad := _choose_pad(animal, from_xz)
	var y := _builder.height_at(pad.x, pad.y) + 0.25
	animal.global_position = Vector3(pad.x, y, pad.y)
	animal.velocity = Vector3.ZERO
	recover_count += 1
	last_reason = reason
	last_animal_id = animal.definition.id
	last_pad = pad
	print(
		"ANIMAL_MAYHEM_2_RECOVER id=",
		animal.definition.id,
		" reason=",
		reason,
		" pad=",
		pad
	)


func _choose_pad(animal: AnimalController, from_xz: Vector2) -> Vector2:
	var pads: Array[Vector2] = [_camp_pad(animal.definition.id)]
	match GameState.step:
		GameState.Step.INTRO, GameState.Step.TREE:
			pass
		GameState.Step.CLIMB:
			pads.append(PAD_POST_TREE)
			pads.append(PAD_CLIMB)
		GameState.Step.COIL:
			pads.append(PAD_POST_TREE)
			pads.append(PAD_CLIMB)
			pads.append(PAD_COIL)
		GameState.Step.EXPLORER, GameState.Step.DONE:
			pads.append(PAD_POST_TREE)
			pads.append(PAD_CLIMB)
			pads.append(PAD_COIL)
			pads.append(PAD_EXPLORER)
	var best := pads[0]
	var best_d := from_xz.distance_squared_to(best)
	for i in range(1, pads.size()):
		var d := from_xz.distance_squared_to(pads[i])
		if d < best_d:
			best = pads[i]
			best_d = d
	return best


func _camp_pad(id: StringName) -> Vector2:
	match id:
		&"buffalo":
			return CAMP_BUFFALO
		&"monkey":
			return CAMP_MONKEY
		&"snake":
			return CAMP_SNAKE
	return CAMP_BUFFALO


func _in_river(xz: Vector2) -> bool:
	return xz.x > RIVER_X_MIN and xz.x < RIVER_X_MAX and xz.y > RIVER_Z_MIN and xz.y < RIVER_Z_MAX


func _snake_puzzle_ok(animal: AnimalController, xz: Vector2) -> bool:
	if animal.definition.id != &"snake":
		return false
	return xz.distance_to(GAP_XZ) <= EXCLUSION_M or xz.distance_to(COIL_XZ) <= EXCLUSION_M


func _near_landmark(xz: Vector2) -> bool:
	if xz.distance_to(TREE_XZ) < 4.5:
		return true
	if xz.distance_to(CLIMB_XZ) < 4.5:
		return true
	if xz.distance_to(GAP_XZ) < 4.5:
		return true
	if xz.distance_to(COIL_XZ) < 4.5:
		return true
	if xz.distance_to(EXPLORER_XZ) < 4.5:
		return true
	return false


func _ensure_index(i: int) -> void:
	while _air_t.size() <= i:
		_air_t.append(0.0)
		_fall_t.append(0.0)
		_river_t.append(0.0)
		_below_t.append(0.0)
		_stuck_t.append(0.0)


func _reset_timers(i: int) -> void:
	_air_t[i] = 0.0
	_fall_t[i] = 0.0
	_river_t[i] = 0.0
	_below_t[i] = 0.0
	_stuck_t[i] = 0.0
