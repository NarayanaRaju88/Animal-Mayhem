class_name AnimalCatalog
extends RefCounted
## Phase 1 roster. Future animals are added here without rewriting movement.

static func all() -> Array[AnimalDefinition]:
	var list: Array[AnimalDefinition] = []
	list.append(_def(&"buffalo", "Buffalo", 4.0, 8.0, 2.6, 0.78, 1.7, PackedStringArray(["force"])))
	list.append(_def(&"monkey", "Monkey", 5.2, 5.4, 2.0, 0.42, 1.15, PackedStringArray(["climb"])))
	list.append(_def(&"snake", "Snake", 4.6, 4.8, 1.6, 0.28, 0.45, PackedStringArray(["coil", "narrow"])))
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
