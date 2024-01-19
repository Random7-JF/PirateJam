extends Node

@export var max_weeds_to_spawn: int = 5
@export var weed_scene: PackedScene
@export var tilemap: TileMap
@export var timer_start: float = 10.0

@onready var timer: Timer = $Timer
@onready var weeds: Node = $Weeds

const TILE_SIZE: int = 32
const WEED_MAX_LEVEL: int = 3
const CAN_GROW: String = "can_grow"

var weed_spawn_locations: Array[Rect2i]

func _ready():
	if not weed_scene:
		printerr("Missing weed_scene")
		return

	for child in $Spawn.get_children():
		weed_spawn_locations.append(child.spawn_area)
	spawn_weeds()

func _on_timer_timeout():
	spawn_weeds()
	grow_weeds()
	timer.wait_time = randf_range( timer_start / 2, timer_start)
	timer.start()

# func _input(event):
# 	if event.is_action_pressed("mouse_left"):
# 		#tilemap_check()
 
#########################################

func tilemap_check(position: Vector2i):
	var clicked_cell = tilemap.local_to_map(position)
	print(clicked_cell)
	var tile_data = tilemap.get_cell_tile_data(1, clicked_cell)
	if tile_data:
		print("can grow -> ", clicked_cell, " : ", tile_data.get_custom_data(CAN_GROW))
	

func get_spawn_location_in_region(region: Rect2i) -> Vector2i:
	return Vector2i(
		randi_range(region.position.x + TILE_SIZE, region.position.x + region.size.x - TILE_SIZE),
		randi_range(region.position.y + TILE_SIZE, region.position.y + region.size.y - TILE_SIZE)
	)

func pick_spawn_coords() -> Vector2i:
	return get_spawn_location_in_region(
		weed_spawn_locations[randi_range(0 , weed_spawn_locations.size() - 1)]
		)

func spawn_weeds() -> void:
	for index in range(0,max_weeds_to_spawn):
		var instance = weed_scene.instantiate()
		instance.global_position = pick_spawn_coords()
		tilemap_check(pick_spawn_coords())
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
