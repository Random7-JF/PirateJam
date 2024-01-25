extends Node2D

@export var tile_map: TileMap
@export var plant_manager: PlantManager
@export var player: Player

# Need to create packed scene
@export var crop_scene: PackedScene = preload("res://scenes/grow_scenes/crop/crop.tscn")
# be able to apply correct crops

@onready var crop_node: Node2D = $Crops

const LOGISTICS_OBJECT_LAYER: int = 0 #Tilemap Layer Number
const CAN_GROW_CROPS: String = "can_grow_crops"

var current_crop: int = 0
var spawn_tiles: Array[Vector2i] = []

func _ready():
	player.connect("plant_action_taken", plant_new_crop)
	spawn_tiles = find_spawn_tiles(tile_map.get_used_rect())
	print("Crop tiles: ", spawn_tiles.size())
	
func find_spawn_tiles(tilemap_area: Rect2i) -> Array[Vector2i]:
	var found_tiles: Array[Vector2i] = []
	for tile_column in range(tilemap_area.position.x,tilemap_area.size.x):
		for tile_row in range(tilemap_area.position.y, tilemap_area.size.y):
			var tile = tile_map.get_cell_tile_data(LOGISTICS_OBJECT_LAYER, Vector2i(tile_row, tile_column))
			if tile:
				var weed_found = tile.get_custom_data(CAN_GROW_CROPS)
				if weed_found:
					var index = found_tiles.find(Vector2i(tile_row, tile_column))
					if index == -1:
						found_tiles.append(Vector2i(tile_row, tile_column))
	return found_tiles

func plant_new_crop(cursor_pos: Vector2, global_pos:Vector2):
	#check if player is in range of cursor
	var tile_coords: Vector2 = tile_map.local_to_map(cursor_pos)
	var player_tile_coords: Vector2  = tile_map.local_to_map(global_pos)
	var distance = tile_coords.distance_to(player_tile_coords)
	#Confirm player is close enough
	if distance > player.action_range:
		print("to far for action")
		return		
	#check if cursor_pos is in spawn_tiles
	var check_index = spawn_tiles.find(Vector2i(tile_coords.x, tile_coords.y))
	if check_index == -1:
		return
	print("Found index:, ", spawn_tiles[check_index])
	#check if the spawn_tile is open via plantmanager
	if plant_manager.check_for_plant(tile_coords):
		#instantiate crop
		var new_crop = crop_scene.instantiate()
		new_crop.global_position = to_global(tile_map.map_to_local(tile_coords))
		crop_node.add_child(new_crop)
		new_crop.set_up_crop(0)
		#update plant manger
		plant_manager.add_plant(tile_coords)
		print("spawned crop at: ", tile_coords)
