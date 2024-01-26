extends Control

@export var player: Player

@onready var plant_icon = $BackgroundContainer/Icons/PlantIcon
@onready var harvest_icon = $BackgroundContainer/Icons/HarvestIcon
@onready var destroy_icon = $BackgroundContainer/Icons/DestroyIcon
@onready var icons = $BackgroundContainer/Icons


@export var harvest_icon_inactive: Texture
@export var harvest_icon_active: Texture
@export var destroy_icon_inactive: Texture
@export var destroy_icon_active: Texture


var seed_inactive: Texture
var seed_active: Texture

var plant_active: bool = false
var harvest_active: bool = false
var destroy_active: bool = false

func _ready():
	player.connect("change_seed", change_seed)
	player.connect("plant_action_selected", plant_action_selected)
	player.connect("harvest_action_selected", harvest_action_selected)
	player.connect("destroy_action_selected", destroy_action_selected)

func change_seed(seeds: Array[Seed], current: int):
	seed_inactive = seeds[current].ui_inactive_texture
	seed_active = seeds[current].ui_active_texture
	if plant_active:
		plant_icon.texture = seed_active
	else:
		plant_icon.texture = seed_inactive


func plant_action_selected(seeds: Array[Seed], current: int):
	plant_active = true
	harvest_active = false
	destroy_active = false
	
	seed_inactive = seeds[current].ui_inactive_texture
	seed_active = seeds[current].ui_active_texture
	
	set_icons_inactive()
	plant_icon.texture = seed_active

func harvest_action_selected():
	plant_active = false
	harvest_active = true
	destroy_active = false
	
	set_icons_inactive()
	harvest_icon.texture = harvest_icon_active

func destroy_action_selected():
	plant_active = false
	harvest_active = false
	destroy_active = true
	
	set_icons_inactive()
	destroy_icon.texture = destroy_icon_active

func set_icons_inactive():
	plant_icon.texture = seed_inactive
	harvest_icon.texture = harvest_icon_inactive
	destroy_icon.texture = destroy_icon_inactive
