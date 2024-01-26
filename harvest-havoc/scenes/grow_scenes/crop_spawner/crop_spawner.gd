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

func plant_new_crop(plant_pos: Vector2):
	var tile_coords: Vector2 = tile_map.local_to_map(plant_pos)
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
		new_crop.connect("crop_removed", remove_crop)
		print("spawned crop at: ", tile_coords)

func remove_crop(coords: Vector2):
	var tile_coords: Vector2 = tile_map.local_to_map(coords)
	plant_manager.remove_plant(tile_coords)
	print("remove crop @ ", coords)
	
