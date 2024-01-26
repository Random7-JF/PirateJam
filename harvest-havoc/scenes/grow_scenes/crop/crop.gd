extends StaticBody2D
class_name Crop

signal crop_removed(coords: Vector2)

@onready var sprite: AnimatedSprite2D = $Sprites
@onready var grow_component: Timer = $GrowComponent

@export var crop_variant: int = -1
@export var crop_max_level: int = 0
@export var crop_level: int = 0


func set_up_crop(new_crop_variant: int):
	crop_variant = new_crop_variant
	sprite.set_animation(StringName(str("crop_", crop_variant)))
	sprite.frame = crop_level
	crop_max_level = sprite.get_sprite_frames().get_frame_count(sprite.animation)

func harvest(player: Player):
	if crop_level ==  crop_max_level:
		player.add_harvested_crop(crop_max_level - 2 , crop_variant)
	else:
		player.add_harvested_crop(crop_level, crop_variant)
	emit_signal("crop_removed", global_position)
	queue_free()

func _on_grow_component_timeout():
	crop_level = min(crop_level + 1, crop_max_level)
	sprite.frame = crop_level

	if crop_level >= crop_max_level:
		grow_component.repeat_timer = false
	else:
		grow_component.setup_new_timer()
