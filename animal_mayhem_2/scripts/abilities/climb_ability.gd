class_name ClimbAbility
extends Ability


func id() -> String:
	return "climb"


func can_use(animal: AnimalController, target: Node3D) -> bool:
	return animal.definition.id == &"monkey" and target is ClimbLedge and not (target as ClimbLedge).used


func execute(animal: AnimalController, target: Node3D) -> bool:
	if not can_use(animal, target):
		return false
	(target as ClimbLedge).climb(animal)
	return true
