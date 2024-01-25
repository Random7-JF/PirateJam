class_name Player
extends CharacterBody2D

signal plant_action_taken(mouse_pos: Vector2, player_pos:Vector2)
signal harvest_action_taken(mouse_pos: Vector2, player_pos:Vector2)
signal destroy_action_taken(mouse_pos: Vector2, player_pos:Vector2)

@export var speed: int = 100
@export var action_cooldown: float = 1.0

@onready var animation_tree = $AnimationTree

var direction: Vector2 = Vector2.ZERO
var action_range: float = 1.0
var time_since_last_action: float = 0
var current_action = Actions.Invalid

enum Actions {
	Plant,Harvest,Destroy,
	Invalid = -1
}

func _ready():
	animation_tree.active = true

func _process(delta):
	update_animations()

func _physics_process(delta):
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	if direction:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
		
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

func _on_action_area_body_entered(body):
	print("Player hit: ", body.name)
	if body is Crop:
		body.harvest()
	if body is Weed:
		body.destory()

		
func update_animations():
	if direction == Vector2.ZERO:
		animation_tree["parameters/conditions/is_idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/is_idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true
		animation_tree["parameters/Idle/blend_position"] = direction
		animation_tree["parameters/Walk/blend_position"] = direction
	
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

