extends Node2D

@export var tile_map: TileMap
@export var plant_manager: PlantManager
@export var player: Player

@export var max_spawned_weeds: int = 15
@export var weed_spawn_delay: float = 10
@export var weed_spawn_variance: float = 2

@onready var weed_node: Node2D = $Weeds
@onready var timer: Timer = $SpawnTimer
@onready var weed_scene: PackedScene = preload("res://scenes/grow_scenes/weed/weed.tscn")

const LOGISTICS_OBJECT_LAYER: int = 0 #Tilemap Layer Number
const CAN_GROW_WEEDS: String = "can_grow_weeds"
const HAS_PLANT: String = "has_plant"

var spawn_tiles: Array[Vector2i] = []
var occupied_tiles: Array[Vector2i] = []

func _ready():
	spawn_tiles = find_spawn_tiles(tile_map.get_used_rect())
	print("spawn tiles found: ", spawn_tiles.size())
	setup_and_start_timer()

func _on_spawn_timer_timeout():
	spawn_weeds(1)

func setup_and_start_timer():
	timer.wait_time = randf_range(weed_spawn_delay - weed_spawn_variance, weed_spawn_delay + weed_spawn_variance)
	timer.start()
	
func spawn_weeds(spawn_count: int) -> void:
	if spawn_count == 0 or weed_node.get_child_count() >= max_spawned_weeds:
		return
	var spawn_tile = pick_spawn_point(spawn_tiles, 3)
	if spawn_tile == Vector2i(0,0):
		return
	#Instance weed at location
	var new_weed = weed_scene.instantiate()
	new_weed.global_position = to_global(tile_map.map_to_local(spawn_tile))
	weed_node.add_child(new_weed)
	#Add coords to store
	plant_manager.add_plant(spawn_tile)
	spawn_weeds(spawn_count - 1)


func find_spawn_tiles(tilemap_area: Rect2i) -> Array[Vector2i]:
	var found_tiles: Array[Vector2i] = []
	for tile_column in range(tilemap_area.position.x,tilemap_area.size.x):
		for tile_row in range(tilemap_area.position.y, tilemap_area.size.y):
			var tile = tile_map.get_cell_tile_data(LOGISTICS_OBJECT_LAYER, Vector2i(tile_row, tile_column))
			if tile:
				var weed_found = tile.get_custom_data(CAN_GROW_WEEDS)
				if weed_found:
					var index = found_tiles.find(Vector2i(tile_row, tile_column))
					if index == -1:
						found_tiles.append(Vector2i(tile_row, tile_column))
	return found_tiles


func pick_spawn_point(spawn_tiles_to_pick: Array[Vector2i], attempts: int) -> Vector2i:
	if attempts == 0:
		return Vector2i()
	var spawn_point = spawn_tiles_to_pick.pick_random()
	if plant_manager.check_for_plant(spawn_point):
		return spawn_point
	else:
		print("retrying...")
		return pick_spawn_point(spawn_tiles_to_pick, attempts - 1)
