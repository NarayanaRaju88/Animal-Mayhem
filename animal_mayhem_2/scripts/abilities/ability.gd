class_name Ability
extends RefCounted
## Base ability. World interactables ask whether the active animal can use them.

func id() -> String:
	return ""


func can_use(_animal: AnimalController, _target: Node3D) -> bool:
	return false


func execute(_animal: AnimalController, _target: Node3D) -> bool:
	return false
