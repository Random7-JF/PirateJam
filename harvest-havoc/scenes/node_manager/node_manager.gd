class_name NodeManager
extends Node2D

@export var crop_manager: CropManager
@export var weed_manager: WeedManager
@export var player: Player
@export var tile_map: TileMap


@onready var timers_node: Node2D = $Timers
@onready var grow_timer: PackedScene = preload("res://scenes/grow_timer/grow_timer.tscn")

var weeds: Array[Vector2i]
var weed_levels: Array[int]
var crops: Array[Vector2i]
var crops_data: Array[Vector2i] # .x level, .y type

const timer_group_name = "grow_timers"

func _ready():
	connect_signals()

################################################################################

func connect_signals() -> void:
	
	player.connect("plant_action_taken", plant_action)
	player.connect("harvest_action_taken", harvest_action)
	player.connect("destroy_action_taken", destroy_action)
	
	weed_manager.connect("weed_spawned", add_weed)
	weed_manager.connect("weed_grew", grow_weed)
	weed_manager.connect("weed_break", break_weed)
	weed_manager.connect("weed_destroyed", destroy_weed)

################################################################################

# create a new timer, add to a group, set the wait time and start the timer.
func create_grow_timer(grow_time: float, variance: float) -> Timer:
	var new_timer: Timer = grow_timer.instantiate()
	var wait_time: float = randf_range(grow_time - variance, grow_time + variance)
	new_timer.wait_time = wait_time
	timers_node.add_child(new_timer)
	new_timer.add_to_group(timer_group_name)
	new_timer.start()
	#print("Create Timer: ", new_timer.name, "Wait time: ", wait_time)
	return new_timer

# grab all timers and pause them until we call to unpause
func pause_grow_timers():
	for timer in get_tree().get_nodes_in_group(timer_group_name):
		timer.set_paused(true)

# grab all timers and resume them until we call to unpause
func resume_grow_timers():
		for timer in get_tree().get_nodes_in_group(timer_group_name):
			timer.set_paused(false)

###############################################################################

func add_weed(weed_position: Vector2i, level: int) -> void:
	weeds.append(weed_position)
	weed_levels.append(level)
	
func grow_weed(weed_position: Vector2i, increase_level_by: int) -> void:
	var index = weeds.find(weed_position)
	if index == -1:
		push_error("Weed Not Found In Array")
		return
	weed_levels[index] += increase_level_by

func break_weed(weed_position: Vector2i, decrease_level_by: int) -> void:
	var index = weeds.find(weed_position)
	if index == -1:
		push_error("Weed Not Found In Array")
		return
	weed_levels[index] -= decrease_level_by
	
func destroy_weed(weed_position: Vector2i) -> void:
	var index = weeds.find(weed_position)
	if index == -1:
		push_error("Weed Not Found In Array")
		return
	weeds.remove_at(index)
	weed_levels.remove_at(index)

###############################################################################

func plant_action(mouse_pos: Vector2, player_pos: Vector2):
	#Convert to tilemap local
	var tile_map_pos = tile_map.local_to_map(mouse_pos)
	print("plant_action: ", tile_map_pos)
	#Confirm player is close enough
	
func harvest_action(mouse_pos: Vector2, player_pos: Vector2):
	#Convert to tilemap local
	var tile_map_pos = tile_map.local_to_map(mouse_pos)
	print("harvest_action: ", tile_map_pos)
	#Confirm player is close enough
	
func destroy_action(mouse_pos: Vector2, player_pos: Vector2):
	#Convert to tilemap local
	var tile_map_pos = tile_map.local_to_map(mouse_pos)
	print("destory_action: ", tile_map_pos)
	#Confirm player is close enough
