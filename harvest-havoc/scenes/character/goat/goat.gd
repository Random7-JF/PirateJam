extends CharacterBody2D

@export var dest: Vector2 = Vector2(950, 530)
@export var speed: int = 100
@onready var nav: NavigationAgent2D = $NavigationAgent2D

# Called when the node enters the scene tree for the first time.
func _ready():
	nav.target_position = dest
	$Sprite.play("walk_right")


func _physics_process(_delta):
	if nav.distance_to_target() >= 1:
		var direction = (nav.get_next_path_position() - global_position).normalized()
		velocity = direction * speed
		move_and_slide()