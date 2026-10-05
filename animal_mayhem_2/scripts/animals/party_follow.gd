class_name PartyFollow
extends RefCounted
## Inactive animals trail the active animal on reachable ground.
## They wait at puzzle gates they cannot pass. They never change GameState,
## collision layers, or abilities.

const ARRIVE_M := 0.95
const SNAP_M := 14.0
const CLIMB_CENTER := Vector2(24.5, 12.0)
const CLIMB_WAIT := Vector2(24.5, 8.2)

var enabled := true
var snap_count := 0
var _builder: JungleBuilder


func setup(builder: JungleBuilder) -> void:
	_builder = builder


func tick(animals: Array[AnimalController], active_index: int) -> void:
	if animals.is_empty():
		return
	for a in animals:
		if not enabled or a == null or a.active or a.definition == null:
			if a:
				a.follow_dir = Vector3.ZERO
				a.follow_speed_scale = 1.0
			continue
		if a.action_name != "":
			a.follow_dir = Vector3.ZERO
			a.follow_speed_scale = 1.0
			continue
		if active_index < 0 or active_index >= animals.size():
			a.follow_dir = Vector3.ZERO
			continue
		var leader := animals[active_index]
		if leader == null or leader == a:
			a.follow_dir = Vector3.ZERO
			continue
		var goal := _goal(a, leader, animals, active_index)
		var pos := Vector2(a.global_position.x, a.global_position.z)
		var delta := goal - pos
		var dist := delta.length()
		if dist > SNAP_M:
			_snap(a, goal, delta)
			continue
		if dist < ARRIVE_M:
			a.follow_dir = Vector3.ZERO
			a.follow_speed_scale = 1.0
			continue
		a.follow_dir = Vector3(delta.x, 0.0, delta.y).normalized()
		a.follow_speed_scale = 1.45 if dist > 6.0 else 1.12


func _goal(
		follower: AnimalController,
		leader: AnimalController,
		animals: Array[AnimalController],
		active_index: int
	) -> Vector2:
	var slot := _formation_slot(follower, leader, animals, active_index)
	slot = _apply_climb(leader, slot)
	var origin := Vector2(follower.global_position.x, follower.global_position.z)
	var margin := follower.definition.collision_radius + 0.35
	if not GameState.tree_cleared:
		slot = _avoid(origin, slot, 11.9, 13.1, -4.25, 4.25, margin)
	if follower.definition.id != &"snake":
		slot = _avoid(origin, slot, 30.4, 32.6, -11.0, -3.0, margin)
		slot = _avoid(origin, slot, 18.0, 34.0, -14.0, -4.0, margin)
	if not GameState.coil_done:
		slot = _avoid(origin, slot, 37.9, 39.1, -3.5, 3.5, margin)
	return slot


func _formation_slot(
		follower: AnimalController,
		leader: AnimalController,
		animals: Array[AnimalController],
		active_index: int
	) -> Vector2:
	var fwd := leader.global_transform.basis.z
	fwd.y = 0.0
	if fwd.length() < 0.05:
		fwd = Vector3(0, 0, 1)
	else:
		fwd = fwd.normalized()
	var right := leader.global_transform.basis.x
	right.y = 0.0
	if right.length() < 0.05:
		right = Vector3(1, 0, 0)
	else:
		right = right.normalized()
	var ordinal := 0
	var seen := 0
	for i in animals.size():
		if i == active_index:
			continue
		if animals[i] == follower:
			ordinal = seen
			break
		seen += 1
	var back := 2.25 + float(ordinal) * 1.2
	var side := -0.65 if ordinal % 2 == 0 else 0.65
	var world := leader.global_position - fwd * back + right * side
	return Vector2(world.x, world.z)


func _apply_climb(leader: AnimalController, slot: Vector2) -> Vector2:
	if _builder == null:
		return slot
	var lxz := Vector2(leader.global_position.x, leader.global_position.z)
	if lxz.distance_to(CLIMB_CENTER) > 5.5:
		return slot
	var ground := _builder.height_at(lxz.x, lxz.y)
	if leader.global_position.y < ground + 1.6:
		return slot
	return CLIMB_WAIT


func _avoid(
		origin: Vector2,
		goal: Vector2,
		min_x: float,
		max_x: float,
		min_z: float,
		max_z: float,
		margin: float
	) -> Vector2:
	return _stop_before(
		origin,
		goal,
		min_x - margin,
		max_x + margin,
		min_z - margin,
		max_z + margin
	)


func _stop_before(
		from: Vector2,
		to: Vector2,
		min_x: float,
		max_x: float,
		min_z: float,
		max_z: float
	) -> Vector2:
	if not _segment_hits_rect(from, to, min_x, max_x, min_z, max_z):
		return to
	var lo := 0.0
	var hi := 1.0
	for _i in 12:
		var mid := (lo + hi) * 0.5
		var p := from.lerp(to, mid)
		if _segment_hits_rect(from, p, min_x, max_x, min_z, max_z):
			hi = mid
		else:
			lo = mid
	var stopped := from.lerp(to, lo)
	if lo > 0.02 and from.distance_to(stopped) > 0.05:
		stopped += (from - stopped).normalized() * 0.2
	return stopped


func _segment_hits_rect(
		a: Vector2,
		b: Vector2,
		min_x: float,
		max_x: float,
		min_z: float,
		max_z: float
	) -> bool:
	var delta := [b.x - a.x, b.y - a.y]
	var origin := [a.x, a.y]
	var bounds := [min_x, max_x, min_z, max_z]
	var tmin := 0.0
	var tmax := 1.0
	for axis in 2:
		var o: float = origin[axis]
		var d: float = delta[axis]
		var mn: float = bounds[axis * 2]
		var mx: float = bounds[axis * 2 + 1]
		if absf(d) < 0.00001:
			if o < mn or o > mx:
				return false
		else:
			var t_a := (mn - o) / d
			var t_b := (mx - o) / d
			if t_a > t_b:
				var tmp := t_a
				t_a = t_b
				t_b = tmp
			tmin = maxf(tmin, t_a)
			tmax = minf(tmax, t_b)
			if tmin > tmax:
				return false
	return tmax >= 0.0 and tmin <= 1.0


func _snap(animal: AnimalController, goal: Vector2, delta: Vector2) -> void:
	var y := 0.3
	if _builder:
		y = _builder.height_at(goal.x, goal.y) + 0.3
	if delta.length() > 0.1:
		animal.rotation.y = atan2(delta.x, delta.y)
	animal.global_position = Vector3(goal.x, y, goal.y)
	animal.velocity = Vector3.ZERO
	animal.follow_dir = Vector3.ZERO
	animal.follow_speed_scale = 1.0
	snap_count += 1
	print("ANIMAL_MAYHEM_2_FOLLOW_SNAP id=", animal.definition.id, " to=", goal)
