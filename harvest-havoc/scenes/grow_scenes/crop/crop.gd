extends StaticBody2D
class_name Crop

@onready var sprite: AnimatedSprite2D = $Sprites
@onready var grow_component: Timer = $GrowComponent

var crop_variant: int = -1
var crop_max_level: int = 0
var crop_level: int = 0


func set_up_crop(new_crop_variant: int):
	crop_variant = new_crop_variant
	sprite.set_animation(StringName(str("crop_0")))
	sprite.frame = crop_level
	crop_max_level = sprite.get_sprite_frames().get_frame_count(sprite.animation)

func harvest():
	print("HARVEST!!!")

func _on_grow_component_timeout():
	crop_level = min(crop_level + 1, crop_max_level)
	sprite.frame = crop_level

	if crop_level >= crop_max_level:
		grow_component.repeat_timer = false
	else:
		grow_component.setup_new_timer()
