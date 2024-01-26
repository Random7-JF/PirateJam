class_name Player
extends CharacterBody2D

signal plant_action_taken(mouse_pos: Vector2, player_pos:Vector2)
#Ui Signals
signal plant_action_selected()
signal harvest_action_selected()
signal destroy_action_selected()

@export var speed: int = 100
@export var action_cooldown: float = 1.0

@onready var action_area = $Action/ActionArea
@onready var animation_tree = $AnimationTree

var direction: Vector2 = Vector2.ZERO
var action_range: float = 1.0
var time_since_last_action: float = 0
var current_action = Actions.Invalid

var plant_body

enum Actions {
	Plant,Harvest,Destroy,
	Invalid = -1
}

func _ready():
	animation_tree.active = true

func _process(delta):
	time_since_last_action += delta
	update_animations()

func _physics_process(_delta):
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
		print("Destory")

func _on_action_area_body_entered(body):
	plant_body = body
	
func _on_action_area_body_exited(body):
	if action_area.has_overlapping_bodies():
		plant_body = action_area.get_overlapping_bodies()[0]
	else:
		plant_body = null
		
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
	
	if current_action == Actions.Plant:
		emit_signal("plant_action_taken", to_global(action_area.position))
	else:
		if plant_body != null:
			if plant_body is Crop and current_action == Actions.Harvest:
				print("Player Harvest Action on -> ", plant_body.name)
				plant_body.harvest(self)
			elif plant_body is Weed and current_action == Actions.Destroy:
				plant_body.destory()
	
	time_since_last_action = 0.0

func add_harvested_crop(crop_amount: int, crop_varaint: int):
	print("Amount: ", crop_amount, "Variant: ", crop_varaint)


