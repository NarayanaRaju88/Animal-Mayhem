class_name AnimalDefinition
extends Resource
## Data for one playable animal. Models/sounds can be swapped later.

@export var id: StringName = &"buffalo"
@export var display_name: String = "Buffalo"
@export var move_speed: float = 4.2
@export var turn_speed: float = 7.0
@export var camera_distance: float = 7.2
@export var camera_height: float = 2.4
@export var collision_radius: float = 0.72
@export var collision_height: float = 1.6
@export var abilities: PackedStringArray = PackedStringArray(["force"])
