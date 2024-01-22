extends TileMap
"""
This is the tilemap manager, this is responsbile for everything tilemap.
Growing weeds on tiles, growing crops on tiles, activating new land,
creating new farm land.
"""
@export var max_spawned_weeds: int = 15
@export var max_weeds_per_spawn: int = 5
@export var weed_spawn_delay: float = 10.0
@export var weed_spawn_delay_variance: float = 4.0

@onready var weed_timer: Timer = $WeedTimer

const TILE_SIZE: int = 32

const CAN_GROW_WEEDS: String = "can_grow_weeds"
const CAN_GROW_CROPS: String = "can_grow_crops"

const SEEDLING_TILE_COORDS: Vector2i = Vector2i(12,9)      #Tilemap Atlas Coords
const SEEDLING_TILE_SOURCE: int = 0                        #Tilemap Source Number
const PLANT_TILE_SOURCE: int = 1                           #Tilemap Source Number
const PLANT_OBJECT_LAYER: int = 3                          #Tilemap Layer Number
const FARM_OBJECT_LAYER: int = 2                           #Tilemap Layer Number

const LOGISTICS_OBJECT_LAYER: int = 0                      #Tilemap Layer Number
const LOGISTICS_TILE_SOURCE: int = 3                       #Tilemap Source Number
const LOGISTICS_WEED_TILE: Vector2i = Vector2i(1,3)        #Tilemap Atlas Coords 
const LOGISTICS_CROP_TILE: Vector2i = Vector2i(3,3)        #Tilemap Atlas Coords

var spawn_tiles: Array[Vector2i]
var current_weeds: Array[Vector2i]
var current_weed_levels: Array[int]
var current_crops: Array[Vector2i]
var current_crops_data: Array[Vector2i] # .x level, .y type
var world: Node2D

func _ready():
	spawn_tiles = find_spawn_tiles(get_used_rect())
	set_weed_timer(weed_spawn_delay)
	spawn_weeds(1)


func _on_weed_timer_timeout():
	spawn_weeds(randi_range(0,max_weeds_per_spawn))
	if current_weeds.size() > 1:
		for weeds in range(1, randi_range(1,max_weeds_per_spawn)):
			grow_weed(current_weeds.pick_random())
	var new_delay: float  = randf_range(weed_spawn_delay - weed_spawn_delay_variance, weed_spawn_delay + weed_spawn_delay_variance)
	set_weed_timer(new_delay)	
	#print("Timer fired, Next delay: ", new_delay )
	#print("current weed count: ", current_weeds.size())
	#print("current weeds: ", current_weeds)

################################################################################
"""
Weed related functions
"""
func set_weed_timer(delay: float):
	weed_timer.wait_time = delay
	weed_timer.start()

func find_spawn_tiles(tilemap_area: Rect2i) -> Array[Vector2i]:
	var found_tiles: Array[Vector2i]
	var weed_tiles: int = 0 #extra var for debugging, could be removed.
	var crop_tiles: int = 0 #extra var for debugging, could be removed.
	for tile_column in range(tilemap_area.position.x,tilemap_area.size.x):
		for tile_row in range(tilemap_area.position.y, tilemap_area.size.y):
			var tile = get_cell_tile_data(LOGISTICS_OBJECT_LAYER, Vector2i(tile_row, tile_column))
			if tile:
				var weed_found = tile.get_custom_data(CAN_GROW_WEEDS)
				var crop_found = tile.get_custom_data(CAN_GROW_CROPS)
				if weed_found or crop_found:
					found_tiles.append(Vector2i(tile_row, tile_column))
				if weed_found: #extra check for debugging, could be removed.
					weed_tiles += 1
				if crop_found: #extra check for debugging, could be removed.
					crop_tiles += 1
	#extra logs, coudl be removed. 
	#print("Found: ", found_tiles.size(), "Min: ", found_tiles.min(), "Max: ", found_tiles.max())
	#print("Weed tiles: ", weed_tiles)
	#print("Crop tiles: ", crop_tiles)
	return found_tiles

func spawn_weeds(spawn_count: int) -> void:
	#print("Spawn weeds: ", spawn_count)
	if spawn_count == 0 or current_weeds.size() >= max_spawned_weeds:
		#print("spawn count or max hit")
		return
	var spawn_pos:Vector2i = spawn_tiles[randi_range(0,spawn_tiles.size()-1)]
	var tile = get_cell_tile_data(PLANT_OBJECT_LAYER, spawn_pos)
	if not tile:
		set_cell(PLANT_OBJECT_LAYER,spawn_pos,PLANT_TILE_SOURCE,Vector2i(0,0)) # 0,0 is level 1
		current_weeds.append(spawn_pos)
		current_weed_levels.append(0)
		spawn_weeds(spawn_count - 1)
	else:
		spawn_weeds(spawn_count)

# uses atlas coords to check weed level
func grow_weed(weed_position: Vector2i, max_level: int = 2) -> void:
	var weed_tile = get_cell_atlas_coords(PLANT_OBJECT_LAYER, weed_position)
	if weed_tile.y >= 0 and weed_tile.y < max_level:
		var index = current_weeds.find(weed_position)
		if  current_weed_levels[index] < max_level:
			current_weed_levels[index] += 1
			set_cell(PLANT_OBJECT_LAYER, current_weeds[index], PLANT_TILE_SOURCE, Vector2i(0 , current_weed_levels[index])) # 0 is level one.
			#print("Growing weed, ", current_weeds[index], " from level ", current_weed_levels[index] - 1, " to ", current_weed_levels[index])

# this function has a lot of break points and needs testing.
func harvest_weed(weed_position: Vector2i) -> void:
	var harvest_tile = get_cell_atlas_coords(PLANT_OBJECT_LAYER, weed_position) # Get the plant layer tile
	var logistics_tile = get_cell_tile_data(LOGISTICS_OBJECT_LAYER, weed_position) # Confirm that it is a tile that can have a weed.
	var index = current_weeds.find(weed_position)
	#print("Harvest_tile: ", harvest_tile)
	if logistics_tile and index != -1:
		var weed_tile = logistics_tile.get_custom_data(CAN_GROW_WEEDS)
		if weed_tile and harvest_tile.y == 0:
			#print("Harvested Weed at ", weed_position)
			current_weed_levels.remove_at(index)
			current_weeds.remove_at(index)
			set_cell(PLANT_OBJECT_LAYER, weed_position, -1)
		else:
			#print("Reduced Weed at ", weed_position)
			current_weed_levels[index] -= 1
			set_cell(PLANT_OBJECT_LAYER, weed_position, PLANT_TILE_SOURCE, Vector2i(0, current_weed_levels[index]))
			
func spread_weed() -> void:
	pass

"""
crop related functions:
"""

