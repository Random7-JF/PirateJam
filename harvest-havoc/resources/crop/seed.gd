extends Resource
class_name Seed

@export var name: String = ""
@export var count: int = 0
@export var seed: int = -1
@export var ui_active_texture: Texture
@export var ui_inactive_texture: Texture

func add_seed(add: int):
	count += add

func set_seed(new_seed: int):
	seed = new_seed
