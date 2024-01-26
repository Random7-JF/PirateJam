extends CharacterBody2D

@export var dest: Vector2 = Vector2(950, 530)
@export var speed: int = 100
@onready var nav: NavigationAgent2D = $NavigationAgent2D

var on_target = false
var have_target = false
var weed_body
var last_ate: float = 0
var eat_cooldown: float = 3

func _ready():
	$Sprite.play("walk_right")

func _physics_process(delta):
	last_ate += delta
	if not have_target:
		var targets = $WeedDetector.get_overlapping_bodies()
		for target in targets:
			if target is Weed:
				have_target = true
				nav.target_position = target.global_position
				print("found weed @, ", target.global_position)
	if not on_target:
		$Sprite.play("walk_right")
		var direction = (nav.get_next_path_position() - global_position).normalized()
		nav.set_velocity(direction * speed)
		
	if weed_body != null:
		if weed_body is Weed and last_ate >= eat_cooldown:
			weed_body.destory()
			$Sprite.play("eat_right")
			last_ate = 0

func weed_finished(coords: Vector2):
	have_target = false
	on_target = false
	
func _on_eating_detector_body_entered(body):
	weed_body = body
	weed_body.connect("weed_removed", weed_finished)
		
func _on_navigation_agent_2d_target_reached():
	on_target = true

func _on_navigation_agent_2d_velocity_computed(safe_velocity:Vector2):
	if not on_target:
		velocity = safe_velocity
		move_and_slide()
