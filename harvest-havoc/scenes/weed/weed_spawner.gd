extends Node2D

@export var max_weeds_to_spawn: int = 5
@export var weed_scene: PackedScene
@export var tilemap: TileMap
@export var timer_start: float = 10.0

@onready var timer: Timer = $Timer
@onready var weeds: Node = $Weeds

const TILE_SIZE: int = 32
const WEED_MAX_LEVEL: int = 3
const CAN_GROW: String = "can_grow"
const OBJECT_LAYER: int = 0
const TILE_SOURCE: int = 4
const GROW_TILE: Vector2i = Vector2i(1,3)

func _ready():
	if not weed_scene:
		printerr("Missing weed_scene")
		return
	spawn_weeds()

func _on_timer_timeout():
	spawn_weeds()
	#grow_weeds()
	timer.wait_time = randf_range( timer_start / 2, timer_start)
	timer.start()
 #########################################

func tilemap_check(tile_position: Vector2i) -> bool:
	#title_position is global
	var check_cell = tilemap.local_to_map(tile_position)
	var tile_data = tilemap.get_cell_tile_data(0, check_cell)
	if tile_data:
		print("can grow -> ", check_cell, " : ", tile_data.get_custom_data(CAN_GROW))
		return true
	else:
		print("can not grow -> ", check_cell)
		return false

func spawn_weeds() -> void: 
	var spawn_tiles: Array[Vector2i] = tilemap.get_used_cells_by_id(OBJECT_LAYER, TILE_SOURCE, GROW_TILE)
	print("Number of spawn tiles: ", spawn_tiles.size())
	for index in range(0,max_weeds_to_spawn):
		var instance = weed_scene.instantiate()
		var spawn_pos:Vector2i = spawn_tiles[randi_range(0,spawn_tiles.size()-1)] * TILE_SIZE
		spawn_pos = spawn_pos + Vector2i(TILE_SIZE / 2, TILE_SIZE /2)
		instance.global_position = spawn_pos
		weeds.add_child(instance)
		print("SpawnPos: ", spawn_pos)

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
