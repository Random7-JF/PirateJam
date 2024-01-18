extends Node2D

@onready var sprite: AnimatedSprite2D = $Sprite

func _ready():
	var weed_level = randi_range(1,4)
	if weed_level == 1:
		sprite.play("weed_1")
	elif weed_level == 2:
		sprite.play("weed_2")
	elif weed_level == 3:
		sprite.play("weed_3")
	else:
		sprite.play("weed_4")

	print(name, " Weed Level: ", weed_level)
