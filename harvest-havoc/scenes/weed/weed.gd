extends Node2D

@onready var sprite: AnimatedSprite2D = $Sprite

@export var lifetime: int = 0: set = set_lifetime
@export var level_up_time: int = 2: set = set_level_up_time
@export var weed_level: int = 0: set = set_level

func _ready():
	set_level(randi_range(1,4))
	update_weed_sprite()

func set_level(new_level: int) -> void:
	weed_level = new_level
	update_weed_sprite()

func set_lifetime(new_lifetime: int) -> void:
	lifetime = new_lifetime

func set_level_up_time(time: int) -> void:
	level_up_time = time


func update_weed_sprite() -> void:
	if weed_level == 1:
		sprite.play("weed_1")
	elif weed_level == 2:
		sprite.play("weed_2")
	else:
		sprite.play("weed_3")
