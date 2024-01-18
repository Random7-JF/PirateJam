extends Node

@export var max_weeds_to_spawn: int = 5
@export var weed_scene: PackedScene
@export var tilemap: TileMap
@export var timer_start: float = 10.0

@onready var timer: Timer = $Timer

var weed_spawn_range: Vector2i
const TILE_SIZE: int = 32

func _ready():
	if not weed_scene:
		printerr("Missing weed_scene")
		return

	weed_spawn_range = get_spawn_range()
	spawn_weeds(weed_spawn_range)
	
func get_spawn_range() -> Vector2i:
	var rect = tilemap.get_used_rect()
	return Vector2i(rect.end.x * TILE_SIZE, rect.end.y * TILE_SIZE)

func get_spawn_location(spawn_range: Vector2i) -> Vector2i:
	return Vector2i(randi_range(0,spawn_range.x),randi_range(0,spawn_range.y))

func spawn_weeds(spawn_range: Vector2):
	for index in range(0,max_weeds_to_spawn):
		var instance = weed_scene.instantiate()
		instance.global_position = get_spawn_location(spawn_range)
		add_child(instance)


func _on_timer_timeout():
	spawn_weeds(weed_spawn_range)
	timer.wait_time = randf_range(0, timer_start)
	timer.start()
