extends Control

@export var player: Player

@onready var units_count = $"MarginContainer/PanelContainer/HBoxContainer/Units Count"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	units_count.text = str(player.units)
