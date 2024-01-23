extends Node2D

@export var tile_map: TileMap

const CAN_GROW_CROPS: String = "can_grow_crops"

const SEEDLING_TILE_COORDS: Vector2i = Vector2i(12,9)      #Tilemap Atlas Coords
const SEEDLING_TILE_SOURCE: int = 0                        #Tilemap Source Number
const PLANT_TILE_SOURCE: int = 1                           #Tilemap Source Number
const PLANT_OBJECT_LAYER: int = 3                          #Tilemap Layer Number
const FARM_OBJECT_LAYER: int = 2                           #Tilemap Layer Number

const LOGISTICS_OBJECT_LAYER: int = 0                      #Tilemap Layer Number
const LOGISTICS_TILE_SOURCE: int = 3                       #Tilemap Source Number
const LOGISTICS_CROP_TILE: Vector2i = Vector2i(3,3)        #Tilemap Atlas Coords

const CARROT_TILES: Vector2i = Vector2i(0,3) # end 4,3
const CARROT_STAGES: int = 4

const PARSNIP_TILES: Vector2i = Vector2i(0,4) # end 4,3
const PARSNIP_STAGES: int = 4

enum CropType {
	CARROT, PARSNIP,
	INVALID = -1
}
var current_crop: CropType = CropType.INVALID

var spawn_tiles: Array[Vector2i]
var current_crops_pos: Array[Vector2i]
var current_crops_data: Array[Vector2i] # .x level, .y type

# Temp for testing purposes.
func _input(event):
	if Input.is_action_just_pressed("select_one"):
		current_crop = CropType.CARROT
		print("Current crop: ", current_crop)
	if Input.is_action_just_pressed("select_two"):
		current_crop = CropType.PARSNIP
		print("Current crop: ", current_crop)
	if Input.is_action_just_pressed("mouse_left"):
		plant_crop(tile_map.local_to_map(get_global_mouse_position()))

################################################################

func plant_crop(crop_position: Vector2i) -> void:
	var logistics_tile = tile_map.get_cell_tile_data(LOGISTICS_OBJECT_LAYER, crop_position)
	if logistics_tile: # null check before custom data
		if logistics_tile.get_custom_data(CAN_GROW_CROPS) and current_crop != -1: # crop tile found
			#check if weed or crop is there
			if tile_map.get_cell_atlas_coords(PLANT_OBJECT_LAYER,crop_position):
				#plant seedling
				#implement recursive handler function based on a timer.
				#Switch on current_crop here, crop type not needed for handle func, just atlas coords
				match current_crop:
					CropType.CARROT:
						handle_crop(current_crop, crop_position, CARROT_TILES, 0, CARROT_STAGES)
					CropType.PARSNIP:
						handle_crop(current_crop, crop_position, PARSNIP_TILES, 0, PARSNIP_STAGES)
				#add to crop array for reference later
				current_crops_pos.append(crop_position)
				current_crops_data.append(Vector2i(0, current_crop))

#recursive func
func handle_crop(crop: CropType, crop_position: Vector2i, atlas_coords: Vector2i, cur_level: int, max_level: int) -> void:
	if cur_level == 0:
		tile_map.set_cell(PLANT_OBJECT_LAYER,crop_position,SEEDLING_TILE_SOURCE,SEEDLING_TILE_COORDS)
	else:
		tile_map.set_cell(PLANT_OBJECT_LAYER,crop_position,PLANT_TILE_SOURCE,atlas_coords)
	
	await $Timers.create_timer(5.0).timeout
	
	if cur_level == max_level:
		return # Done with the crop
	else:
		var new_atlas: Vector2i = Vector2i(atlas_coords.x + 1, atlas_coords.y)
		var index = current_crops_pos.find(crop_position)
		current_crops_data[index] = Vector2i(cur_level + 1, current_crops_data[index].y)
		print("Data: ", current_crops_data)
		handle_crop(crop,crop_position, new_atlas, cur_level+1, max_level)
	
