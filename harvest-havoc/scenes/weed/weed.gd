extends Node2D

@onready var sprite: AnimatedSprite2D = $Sprite

@export var lifetime: int = 0
@export var level_up_time: int = 2
@export var weed_level: int = 1: set = set_level

const WEED_MAX_LEVEL: int = 3

var game_manager: Node

func _ready():
	game_manager = get_tree().get_current_scene().get_node("GameManager")
	game_manager.connect("lifetime_tick", level_up)
	Events.emit_signal("weed_spawned")
	update_weed_sprite()

func update_weed_sprite() -> void:
	if weed_level == 1:
		sprite.play("weed_1")
	elif weed_level == 2:
		sprite.play("weed_2")
	else:
		sprite.play("weed_3")

func set_level(new_level: int) -> void:
	weed_level = new_level
	update_weed_sprite()

func level_up() -> void:
	if  lifetime >= level_up_time and weed_level < WEED_MAX_LEVEL:
		if randi_range(1,2) % 2 == 0:
				set_level(weed_level + 1)
				lifetime = 0
				level_up_time = (weed_level * level_up_time / 2)
				Events.emit_signal("weed_grew")
				print("Growing weed -> ", name, " from ", weed_level, " to ", weed_level +1)
	else:
		lifetime += 1
