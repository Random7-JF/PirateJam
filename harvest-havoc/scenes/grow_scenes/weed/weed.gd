extends StaticBody2D
class_name Weed

signal weed_removed(coords: Vector2)

@onready var sprite: AnimatedSprite2D = $WeedSprites
@onready var grow_component: Timer = $GrowComponent

var weed_variant: int = 1
var weed_max_level: int = 2
var weed_level: int = 0

func _ready():
	weed_variant = randi_range(0,2)
	update_sprite()

func _on_grow_component_timeout():
	weed_level = min(weed_level + 1, weed_max_level)
	sprite.frame = weed_level
	
	if weed_level >= weed_max_level:
		grow_component.repeat_timer = false
	else:
		grow_component.setup_new_timer()
		
func update_sprite():
	sprite.animation = StringName(str("weed_", weed_variant))
	sprite.frame = weed_level
	
func destory():
	grow_component.paused = true
	if weed_level == 0:
		emit_signal("weed_removed", global_position)
		queue_free()
	elif  weed_level >= 1:
		weed_level = weed_level -1
		update_sprite()
	grow_component.setup_new_timer()
	grow_component.paused = false
