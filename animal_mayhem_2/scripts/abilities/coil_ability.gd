class_name CoilAbility
extends Ability


func id() -> String:
	return "coil"


func can_use(animal: AnimalController, target: Node3D) -> bool:
	return animal.definition.id == &"snake" and target is CoilPost and not (target as CoilPost).coiled


func execute(animal: AnimalController, target: Node3D) -> bool:
	if not can_use(animal, target):
		return false
	(target as CoilPost).coil(animal)
	return true
