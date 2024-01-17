extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if randi_range(1,2) % 2 == 0:
		$Sprite.play("walk_left")
	else:
		$Sprite.play("eat_right")

