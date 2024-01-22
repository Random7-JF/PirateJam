extends Node2D

@export var cur_spawn_count: int = 5
@export var max_spawned: int = 25
@export var weed_scene: PackedScene
@export var tilemap: TileMap
@export var timer_start: float = 10.0

@onready var timer: Timer = $Timer
@onready var weeds: Node = $Weeds

const TILE_SIZE: int = 32
const CAN_GROW_WEEDS: String = "can_grow_weeds"
const CAN_GROW_CROPS: String = "can_grow_crops"
const OBJECT_LAYER: int = 0
const TILE_SOURCE: int = 4
const WEED_GROW_TILE: Vector2i = Vector2i(1,3)
const CROP_GROW_TILE: Vector2i = Vector2i(3,3)

var spawn_tiles: Array[Vector2i]
var game_manager: Node

func _ready():
	if not weed_scene:
		printerr("Missing weed_scene")
		return
	game_manager = get_tree().get_current_scene().get_node("GameManager")
	find_spawn_tiles()

func _on_timer_timeout():
	spawn_weeds()
	timer.wait_time = randf_range( timer_start / 2, timer_start)
	timer.start()

#########################################
#########################################

func find_spawn_tiles() -> void:
	spawn_tiles = tilemap.get_used_cells_by_id(OBJECT_LAYER, TILE_SOURCE, WEED_GROW_TILE)
	print("Found spawn tiles: %d" % spawn_tiles.size())
	spawn_tiles.append_array(tilemap.get_used_cells_by_id(OBJECT_LAYER, TILE_SOURCE, CROP_GROW_TILE))
	print("Found spawn tiles: %d" % spawn_tiles.size())

func spawn_weeds() -> void: 
	if weeds.get_child_count() < max_spawned:
		for index in range(0,cur_spawn_count):
			var instance = weed_scene.instantiate()
			var spawn_pos:Vector2i = spawn_tiles[randi_range(0,spawn_tiles.size()-1)] * TILE_SIZE
			spawn_pos = spawn_pos + Vector2i(TILE_SIZE / 2, TILE_SIZE /2)
			instance.global_position = spawn_pos
			weeds.add_child(instance)
	else:
		print("current max weed count reached: %d" % weeds.get_child_count())
