extends Node2D
class_name GameWorld

signal no_more_goats()

@export var goat_spawns: Array[Vector2]
@onready var goat_scene: PackedScene = preload("res://scenes/character/goat/goat.tscn")
var goats: int = 1

func _ready():
	print($TileMap.get_used_rect())

func spawn_goat():
	if goats < 3:
		var new_goat = goat_scene.instantiate()
		new_goat.global_position = goat_spawns.pick_random()
		add_child(new_goat)
		goats += 1
		print(goats)
	if goats >= 3:
		emit_signal("no_more_goats")

