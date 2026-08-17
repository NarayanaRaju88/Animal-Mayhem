class_name ForceAbility
extends Ability


func id() -> String:
	return "force"


func can_use(animal: AnimalController, target: Node3D) -> bool:
	return animal.definition.id == &"buffalo" and target is FallenTree and not (target as FallenTree).moved


func execute(animal: AnimalController, target: Node3D) -> bool:
	if not can_use(animal, target):
		return false
	(target as FallenTree).push(animal)
	return true
