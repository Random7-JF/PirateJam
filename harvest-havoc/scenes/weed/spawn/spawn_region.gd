extends Node2D

@onready var marker_tr: Marker2D = $SpawnMarkerTR
@onready var marker_bl: Marker2D = $SpawnMarkerBL

@export var placeholder: PackedScene

var spawn_area: Rect2

func _ready():
	#spawn_area = Rect2(marker_tr.position.x, marker_tr.position.y, 
	#(marker_tl.position.x - marker_tr.position.x),  
	#(marker_bl.position.y - marker_tr.position.y))
	spawn_area = Rect2(marker_tr.position, marker_bl.position - marker_tr.position)
	print(spawn_area)
	if not placeholder:
		printerr("No placeholder")
		return
	
	var instanceTR = placeholder.instantiate()
	instanceTR.global_position = spawn_area.position
	instanceTR.get_node("Icon").visible = true
	add_child(instanceTR)

	var instanceBL= placeholder.instantiate()
	instanceBL.global_position = spawn_area.position + spawn_area.size
	instanceBL.get_node("Icon").visible = true
	add_child(instanceBL)
	