class_name Player
extends CharacterBody2D

signal plant_action_taken(mouse_pos: Vector2, player_pos:Vector2)
signal harvest_action_taken(mouse_pos: Vector2, player_pos:Vector2)
signal destroy_action_taken(mouse_pos: Vector2, player_pos:Vector2)

@export var speed: float = 100
@export var acceleration: float = 10.0
@export var action_cooldown: float = 1.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var action_range: float = 1.0

enum Actions {
	Plant,Harvest,Destroy,
	Invalid = -1
}

var time_since_last_action: float = 0
var current_action = Actions.Invalid

func _ready():
	time_since_last_action = action_cooldown
	sprite.play("default")

func _physics_process(delta):
	time_since_last_action += delta
	var direction: Vector2 = Input.get_vector("move_left","move_right","move_up","move_down")
	velocity.x = move_toward(velocity.x, speed * direction.x, acceleration)
	velocity.y = move_toward(velocity.y, speed * direction.y, acceleration)

	move_and_slide()

func _input(_event):
	if Input.is_action_just_pressed("action"):
		action()
	if Input.is_action_just_pressed("select_action_1"):
		current_action = Actions.Plant
		print("Planting")
	if Input.is_action_just_pressed("select_action_2"):
		current_action = Actions.Harvest
		print("Harvest")
	if Input.is_action_just_pressed("select_action_3"):
		current_action = Actions.Destroy
		print("Destroy")

###############################################################################

func action():
	if time_since_last_action < action_cooldown:
		return
	var cursor_pos = get_global_mouse_position()
	match current_action:
		Actions.Invalid:
			print("No action")
		Actions.Plant:
			emit_signal("plant_action_taken", cursor_pos, global_position)
		Actions.Harvest:
			emit_signal("harvest_action_taken", cursor_pos, global_position)
		Actions.Destroy:
			emit_signal("destroy_action_taken", cursor_pos, global_position)

	time_since_last_action = 0.0
	

