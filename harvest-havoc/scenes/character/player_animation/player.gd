class_name Player
extends CharacterBody2D

signal plant_action_taken(mouse_pos: Vector2, player_pos:Vector2)

#Ui Signals
signal plant_action_selected(seeds: Array[Seed], current: int)
signal harvest_action_selected()
signal destroy_action_selected()
signal change_seed(seeds: Array[Seed], current: int)


@export var speed: int = 100
@export var action_cooldown: float = 0.7
@export var seeds: Array[Seed]


@export var plant_sounds: Array[AudioStream]
@export var harvest_sounds: Array[AudioStream]
@export var destroy_sounds: Array[AudioStream]

@export var shop_ui: Control
@export var shop_sound: AudioStream

@onready var action_area = $Action/ActionArea
@onready var animation_tree = $AnimationTree
@onready var audio_stream_player = $AudioStreamPlayer

const CARROT = preload("res://resources/crop/carrot.tres")
const PARSNIP = preload("res://resources/crop/parsnip.tres")
const PUMPKIN = preload("res://resources/crop/pumpkin.tres")
const TOMATO = preload("res://resources/crop/tomato.tres")

var direction: Vector2 = Vector2.ZERO
var action_range: float = 1.0
var time_since_last_action: float = 0
var current_action = Actions.Invalid
var current_seed = 0

var plant_body

var is_destorying: bool = false
var is_planting: bool = false
var is_harvesting: bool = false

enum Actions {
	Plant,Harvest,Destroy,
	Invalid = -1
}

func _ready():
	#add_seeds(1,5)
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
		emit_signal("plant_action_selected", seeds, min(current_seed, seeds.size() -1))
	if Input.is_action_just_pressed("select_action_2"):
		current_action = Actions.Harvest
		emit_signal("harvest_action_selected")
	if Input.is_action_just_pressed("select_action_3"):
		current_action = Actions.Destroy
		emit_signal("destroy_action_selected")
	if Input.is_action_just_pressed("cycle_seeds"):
		if current_seed < seeds.size() - 1:
			current_seed += 1
		elif current_seed == seeds.size() - 1:
			current_seed = 0
		print(current_seed)
		print("min: ",  min(current_seed, seeds.size() -1))		
		emit_signal("change_seed", seeds, min(current_seed, seeds.size() -1))

func _on_action_area_body_entered(body):
	plant_body = body
	
func _on_action_area_body_exited(_body):
	if action_area.has_overlapping_bodies():
		plant_body = action_area.get_overlapping_bodies()[0]
	else:
		plant_body = null

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "scythe_down" or anim_name == "scythe_up" or anim_name == "scythe_left" or anim_name == "scythe_right":
		is_destorying = false
	if anim_name == "planting_down" or anim_name == "planting_up" or anim_name == "planting_left" or anim_name == "planting_right":
		is_planting = false
	if anim_name == "harvest_down" or anim_name == "harvest_up" or anim_name == "harvest_left" or anim_name == "harvest_right":
		is_harvesting = false
		
func update_animations():
	if direction == Vector2.ZERO:
		animation_tree["parameters/conditions/is_idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/is_idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true
		animation_tree["parameters/Idle/blend_position"] = direction
		animation_tree["parameters/Walk/blend_position"] = direction
		animation_tree["parameters/Destroy/blend_position"] = direction
		animation_tree["parameters/Planting/blend_position"] = direction
		animation_tree["parameters/Harvesting/blend_position"] = direction
	
	animation_tree["parameters/conditions/is_destroying"] = is_destorying
	animation_tree["parameters/conditions/is_planting"] = is_planting
	animation_tree["parameters/conditions/is_harvesting"] = is_harvesting

func action():
	if time_since_last_action < action_cooldown:
		return
	if current_action == Actions.Plant:
		emit_signal("plant_action_taken", to_global(action_area.position))
		is_planting = true
		audio_stream_player.stream = plant_sounds.pick_random()
		audio_stream_player.play()
	else:
		if plant_body != null:
			if plant_body is Crop and current_action == Actions.Harvest:
				is_harvesting = true
				plant_body.harvest(self)
				audio_stream_player.stream = harvest_sounds.pick_random()
				audio_stream_player.play()
			elif plant_body is Weed and current_action == Actions.Destroy:
				plant_body.destory()
				is_destorying = true
				audio_stream_player.stream = destroy_sounds.pick_random()
				audio_stream_player.play()
	
	time_since_last_action = 0.0

func get_current_seeds() -> Array[Seed]:
	var cur_seeds: Array[Seed]
	for seed in seeds:
		if seed.count > 0:
			cur_seeds.append(seed)
	return cur_seeds

func add_harvested_crop(crop_amount: int, crop_varaint: int):
	print("Amount: ", crop_amount, " Variant: ", crop_varaint)

func add_seeds(seed_type: int, add_count: int):
	if seed_type == 1:
		seeds.append(PARSNIP)
		print("Add Seeds to player")
	if seed_type == 2:
		seeds.append(PUMPKIN)
		print("Add Seeds to player")
	if seed_type == 3:
		seeds.append(TOMATO)
		print("Add Seeds to player")

func toggle_shop_ui():
	shop_ui.visible = !shop_ui.visible
	audio_stream_player.stream = shop_sound
	audio_stream_player.play()
