class_name AnimalCatalog
extends RefCounted
## Phase 1 roster. Future animals are added here without rewriting movement.

static func all() -> Array[AnimalDefinition]:
	var list: Array[AnimalDefinition] = []
	list.append(_def(&"buffalo", "Buffalo", 3.8, 5.6, 2.15, 0.82, 1.75, PackedStringArray(["force"])))
	list.append(_def(&"monkey", "Monkey", 5.0, 3.55, 1.45, 0.4, 1.2, PackedStringArray(["climb"])))
	list.append(_def(&"snake", "Snake", 4.4, 2.95, 1.05, 0.3, 0.48, PackedStringArray(["coil", "narrow"])))
	return list


static func _def(
		id: StringName,
		name: String,
		speed: float,
		cam_dist: float,
		cam_h: float,
		radius: float,
		height: float,
		abilities: PackedStringArray
	) -> AnimalDefinition:
	var d := AnimalDefinition.new()
	d.id = id
	d.display_name = name
	d.move_speed = speed
	d.camera_distance = cam_dist
	d.camera_height = cam_h
	d.collision_radius = radius
	d.collision_height = height
	d.abilities = abilities
	return d
