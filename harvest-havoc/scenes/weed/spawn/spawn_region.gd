extends Node2D

@onready var marker_tr: Marker2D = $SpawnMarkerTR
@onready var marker_bl: Marker2D = $SpawnMarkerBL

var spawn_area: Rect2i

func _ready():
	spawn_area = Rect2i(marker_tr.position, marker_bl.position - marker_tr.position)
