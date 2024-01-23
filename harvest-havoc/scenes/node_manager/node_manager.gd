class_name NodeManager
extends Node2D

@export var crop_manager: CropManager
@export var weed_manager: WeedManager

@onready var timers_node: Node2D = $Timers
@onready var grow_timer: PackedScene = preload("res://scenes/grow_timer/grow_timer.tscn")

const timer_group_name = "grow_timers"

# create a new timer, add to a group, set the wait time and start the timer.
func create_grow_timer(grow_time: float, variance: float) -> Timer:
	var new_timer: Timer = grow_timer.instantiate()
	var wait_time: float = randf_range(grow_time - variance, grow_time + variance)
	new_timer.wait_time = wait_time
	timers_node.add_child(new_timer)
	new_timer.add_to_group(timer_group_name)
	new_timer.start()
	print("Create Timer: ", new_timer.name, "Wait time: ", wait_time)
	return new_timer

# grab all timers and pause them until we call to unpause
func pause_grow_timers():
	for timer in get_tree().get_nodes_in_group(timer_group_name):
		timer.set_paused(true)

# grab all timers and resume them until we call to unpause
func resume_grow_timers():
		for timer in get_tree().get_nodes_in_group(timer_group_name):
			timer.set_paused(false)

func _input(_event):
	if Input.is_action_just_pressed("pause_timers"):
		print("Pausing..")
		pause_grow_timers()
	if Input.is_action_just_pressed("resume_timers"):
		print("Resuming..")
		resume_grow_timers()
