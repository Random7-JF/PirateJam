extends CharacterBody2D

@export var dest: Vector2 = Vector2(950, 530)
@export var speed: int = 100
@onready var nav: NavigationAgent2D = $NavigationAgent2D

var on_target = false

# Called when the node enters the scene tree for the first time.
func _ready():
	nav.target_position = dest
	$Sprite.play("walk_right")


func _physics_process(_delta):
	#print("distance: ", nav.distance_to_target())
	if not on_target:
		var direction = (nav.get_next_path_position() - global_position).normalized()
		nav.set_velocity(direction * speed)

func _on_navigation_agent_2d_target_reached():
	print("on_navigation_agent_2d_target_reached")
	on_target = true
	
func _on_navigation_agent_2d_velocity_computed(safe_velocity:Vector2):
	if not on_target:
		velocity = safe_velocity
		move_and_slide()