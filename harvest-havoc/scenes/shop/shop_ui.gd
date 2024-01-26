extends Control

@export var player: Player


@onready var current_units = $HBoxContainer/Currency/Spacer/current_units
@onready var buy_seeds = $HBoxContainer/Buy/BuySeeds
@onready var buy_seeds_label = $HBoxContainer/Buy/BuySeeds/BuySeeds


var seed_stock = 1
var max_speed_stock = 4

func _ready():
	update_units(player.units)
	
func update_units(amount: int):
	current_units.text = str(amount)

func _on_buy_goat_pressed():
	print("TODO make work")

func _on_buy_seeds_pressed():
	player.add_seeds(seed_stock, 5)
	player.spend_units(20)
	update_units(player.units)
	seed_stock = min(seed_stock + 1, max_speed_stock)
	if seed_stock == 4:
		buy_seeds.disabled = true
		buy_seeds_label.visible = false
		
func _on_pay_rent_pressed():
	player.spend_units(100)
	update_units(player.units)
	player.rent_payed = true


func _on_crops_pressed():
	print("TODO make work")
