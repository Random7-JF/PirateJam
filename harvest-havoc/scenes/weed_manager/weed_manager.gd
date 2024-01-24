class_name WeedManager
extends Node2D

signal weed_spawned(weed_position: Vector2i, level: int)
signal weed_grew(weed_position: Vector2i, incease_level_by: int)
signal weed_break(weed_position: Vector2i, decrease_level_by: int)
signal weed_destroyed(weed_postion: Vector2i)

@export var max_spawned_weeds: int = 15
@export var max_weeds_per_spawn: int = 5
@export var weed_spawn_delay: float = 10.0
@export var weed_spawn_delay_variance: float = 4.0
@export var weed_grow_delay: float = 10
@export var weed_grow_variance: float = 3
@export var spread_chance: int = 40
@export var node_manager: NodeManager
@export var tile_map: TileMap

@onready var weed_timer: Timer = $WeedSpawnTimer

const TILE_SIZE: int = 32

const CAN_GROW_WEEDS: String = "can_grow_weeds"
const CAN_GROW_CROPS: String = "can_grow_crops"

const SEEDLING_TILE_COORDS: Vector2i = Vector2i(12,9)      #Tilemap Atlas Coords
const SEEDLING_TILE_SOURCE: int = 0                        #Tilemap Source Number
const PLANT_TILE_SOURCE: int = 1                           #Tilemap Source Number
const PLANT_OBJECT_LAYER: int = 3                          #Tilemap Layer Number
const FARM_OBJECT_LAYER: int = 2                           #Tilemap Layer Number
const WEED_TILES_START: Vector2i = Vector2i(0,0)

const LOGISTICS_OBJECT_LAYER: int = 0                      #Tilemap Layer Number
const LOGISTICS_TILE_SOURCE: int = 3                       #Tilemap Source Number
const LOGISTICS_WEED_TILE: Vector2i = Vector2i(1,3)        #Tilemap Atlas Coords 
const LOGISTICS_CROP_TILE: Vector2i = Vector2i(3,3)        #Tilemap Atlas Coords

var spawn_tiles: Array[Vector2i]
var world: Node2D

func _ready():
	spawn_tiles = find_spawn_tiles(tile_map.get_used_rect())
	set_weed_timer(weed_spawn_delay)
	spawn_weeds(1)


func _on_weed_timer_timeout():
	spawn_weeds(randi_range(0,max_weeds_per_spawn))
	var new_delay: float  = randf_range(weed_spawn_delay - weed_spawn_delay_variance, weed_spawn_delay + weed_spawn_delay_variance)
	set_weed_timer(new_delay)	


################################################################################
"""
Weed related functions
"""
func set_weed_timer(delay: float):
	weed_timer.wait_time = delay
	weed_timer.start()

func find_spawn_tiles(tilemap_area: Rect2i) -> Array[Vector2i]:
	var found_tiles: Array[Vector2i] = []
	for tile_column in range(tilemap_area.position.x,tilemap_area.size.x):
		for tile_row in range(tilemap_area.position.y, tilemap_area.size.y):
			var tile = tile_map.get_cell_tile_data(LOGISTICS_OBJECT_LAYER, Vector2i(tile_row, tile_column))
			if tile:
				var weed_found = tile.get_custom_data(CAN_GROW_WEEDS)
				var crop_found = tile.get_custom_data(CAN_GROW_CROPS)
				if weed_found or crop_found:
					found_tiles.append(Vector2i(tile_row, tile_column))
	return found_tiles

func spawn_weeds(spawn_count: int) -> void:
	if spawn_count == 0 or node_manager.weeds.size() >= max_spawned_weeds:
		return
		
	var spawn_pos:Vector2i = spawn_tiles[randi_range(0,spawn_tiles.size()-1)]
	var tile = tile_map.get_cell_tile_data(PLANT_OBJECT_LAYER, spawn_pos)
	if not tile:
		handle_weed(spawn_pos,WEED_TILES_START, 0, 2)
		emit_signal("weed_spawned", spawn_pos, 0)
		spawn_weeds(spawn_count - 1)
	else:
		spawn_weeds(spawn_count)

func handle_weed(weed_position: Vector2i, atlas_coords: Vector2i, current_level: int, max_level: int = 2) -> void:
	#print("Params: ", weed_position, atlas_coords, current_level, max_level)
	if current_level > max_level:
		spread_weed(weed_position)
		return
	tile_map.set_cell(PLANT_OBJECT_LAYER, weed_position, PLANT_TILE_SOURCE, atlas_coords)
	
	var timer = node_manager.create_grow_timer(weed_grow_delay, weed_grow_variance)
	await timer.timeout
	timer.queue_free()
	if (node_manager.weeds.find(weed_position) == -1): # weed was removed before fully growing
		return
	
	emit_signal("weed_grew", weed_position, current_level + 1)
	var new_atlas_coords: Vector2i = Vector2i(atlas_coords.x,  atlas_coords.y + 1)
	handle_weed(weed_position, new_atlas_coords, current_level + 1, max_level)
	
# this function has a lot of break points and needs testing.
func destory_weed(weed_position: Vector2i) -> void:
	var harvest_tile = tile_map.get_cell_atlas_coords(PLANT_OBJECT_LAYER, weed_position) # Get the plant layer tile
	var logistics_tile = tile_map.get_cell_tile_data(LOGISTICS_OBJECT_LAYER, weed_position) # Confirm that it is a tile that can have a weed.
	var index = node_manager.weeds.find(weed_position)
	if logistics_tile and index != -1:
		var weed_tile = logistics_tile.get_custom_data(CAN_GROW_WEEDS)
		if weed_tile and harvest_tile.y <= 0:
			emit_signal("weed_destroyed", weed_position)
			tile_map.set_cell(PLANT_OBJECT_LAYER, weed_position, -1)
		else:
			emit_signal("weed_break", weed_position, 1)
			tile_map.set_cell(PLANT_OBJECT_LAYER, weed_position, PLANT_TILE_SOURCE, Vector2i(0, min( 0, node_manager.weed_levels[index] - 1 )))
			
func spread_weed(weed_position: Vector2i) -> void:
	var chance = randi_range(1,100)
	#print("Spread: ", chance, " Chance: ", spread_chance, " Result: ", chance < spread_chance)
	if chance < spread_chance:
		var close_tiles = tile_map.get_surrounding_cells(weed_position)
		var open_tiles: Array[Vector2i]
		for tile in close_tiles:
			var atlas_coords = tile_map.get_cell_atlas_coords(PLANT_OBJECT_LAYER, tile)
			var logistics_tile = tile_map.get_cell_tile_data(LOGISTICS_OBJECT_LAYER, tile)
			if logistics_tile:
				var weed_tile = logistics_tile.get_custom_data(CAN_GROW_WEEDS)
				if atlas_coords == Vector2i(-1,-1) and logistics_tile.get_custom_data(CAN_GROW_WEEDS):
					open_tiles.append(tile)
		
		var spread = open_tiles.pick_random()
		if spread:
			handle_weed(spread, WEED_TILES_START, 0)
