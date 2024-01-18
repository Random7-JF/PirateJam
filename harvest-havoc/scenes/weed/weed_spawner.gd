extends Node

@export var max_weeds_to_spawn: int = 5
@export var weed_scene: PackedScene
@export var tilemap: TileMap

var weed_spawn_range: Vector2i

func _ready():
	if not weed_scene:
		printerr("Missing weed_scene")
		return
	weed_spawn_range = get_spawn_range()
	spawn_weeds(weed_spawn_range)
	
func get_spawn_range() -> Vector2i:
	var rect = tilemap.get_used_rect()
	var tile_size = tilemap.get_rendering_quadrant_size()
	return Vector2(rect.end.x * tile_size, rect.end.y * tile_size)

func get_spawn_location(spawn_range: Vector2i) -> Vector2i:
	return Vector2i(randi_range(0,spawn_range.x),randi_range(0,spawn_range.y))

func spawn_weeds(spawn_range: Vector2):
	for index in range(0,max_weeds_to_spawn):
		var instance = weed_scene.instantiate()
		instance.global_position = get_spawn_location(spawn_range)
		add_child(instance)
