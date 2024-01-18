extends Node

@export var max_weeds_to_spawn: int = 5
@export var weed_scene: PackedScene
@export var tilemap: TileMap
@export var timer_start: float = 10.0

@onready var timer: Timer = $Timer
@onready var weeds: Node = $Weeds

const TILE_SIZE: int = 32
const WEED_MAX_LEVEL: int = 4

var weed_spawn_range: Vector2i

func _ready():
	if not weed_scene:
		printerr("Missing weed_scene")
		return
	weed_spawn_range = get_spawn_range()
	spawn_weeds(weed_spawn_range)

func _on_timer_timeout():
		spawn_weeds(weed_spawn_range)
		grow_weeds()
		timer.wait_time = randf_range(0, timer_start)
		timer.start()
#########################################

func get_spawn_range() -> Vector2i:
	var rect = tilemap.get_used_rect()
	return Vector2i(rect.end.x * TILE_SIZE, rect.end.y * TILE_SIZE)

func get_spawn_location(spawn_range: Vector2i) -> Vector2i:
	return Vector2i(randi_range(0,spawn_range.x),randi_range(0,spawn_range.y))

func spawn_weeds(spawn_range: Vector2):
	for index in range(0,max_weeds_to_spawn):
		var instance = weed_scene.instantiate()
		instance.global_position = get_spawn_location(spawn_range)
		weeds.add_child(instance)

func grow_weeds() -> void:
	var current_weeds = weeds.get_children()
	for weed in current_weeds:
		if  weed.lifetime >= weed.level_up_time and weed.weed_level < WEED_MAX_LEVEL:
			if randi_range(1,2) % 2 == 0:
				weed.set_level(weed.weed_level + 1)
				weed.set_lifetime(0)
				weed.set_level_up_time(weed.weed_level * weed.level_up_time / 2)
				print("Growing weed -> ", weed.name, " from ", weed.weed_level, " to ", weed.weed_level +1)
		else:
			weed.set_lifetime(weed.lifetime + 1)
