class_name InteractProbe
extends Area3D
## Finds nearby interactables for the active animal.

var current: Node3D
var current_ability := ""


func _ready() -> void:
	monitoring = true
	var col := CollisionShape3D.new()
	var sph := SphereShape3D.new()
	sph.radius = 3.2
	col.shape = sph
	add_child(col)


func scan(animal: AnimalController) -> void:
	current = null
	current_ability = ""
	if animal == null:
		return
	for body in get_overlapping_bodies():
		if body is FallenTree and animal.has_ability("force") and not (body as FallenTree).moved:
			current = body
			current_ability = "force"
			return
		if body is ClimbLedge and animal.has_ability("climb") and not (body as ClimbLedge).used:
			current = body
			current_ability = "climb"
			return
		if body is CoilPost and animal.has_ability("coil") and not (body as CoilPost).coiled:
			current = body
			current_ability = "coil"
			return
