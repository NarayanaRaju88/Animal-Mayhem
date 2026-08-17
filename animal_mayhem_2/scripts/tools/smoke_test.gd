extends SceneTree
## Headless smoke: load the main scene and quit.

func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	if packed == null:
		push_error("main.tscn failed to load")
		quit(1)
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	print("ANIMAL_MAYHEM_2_SMOKE_OK")
	quit(0)
