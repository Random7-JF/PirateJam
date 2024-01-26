extends Control

@export var player: Player
@export var world: GameWorld

@onready var current_units = $HBoxContainer/Currency/Spacer/current_units
@onready var buy_seeds = $HBoxContainer/Buy/BuySeeds
@onready var buy_seeds_label = $HBoxContainer/Buy/BuySeeds/BuySeeds
@onready var buy_goat = $HBoxContainer/Buy/BuyGoat
@onready var buy_goat_label = $HBoxContainer/Buy/BuyGoat/Label

@onready var rent_due = $HBoxContainer/Buy/Spacer/RentDue
@onready var rent_total = $HBoxContainer/Buy/Spacer/RentTotal
@onready var pay_rent = $HBoxContainer/Buy/PayRent
@onready var pay_rent_label = $HBoxContainer/Buy/PayRent/Label

var seed_stock = 1
var max_speed_stock = 4

func _ready():
	world.connect("no_more_goats", no_more_goat)
	update_units(player.units)

func no_more_goat():
	buy_goat.disabled = true
	buy_goat_label.visible = false
	
func update_units(amount: int):
	current_units.text = str(amount)

func _on_buy_goat_pressed():
	player.spend_units(125)
	update_units(player.units)
	world.spawn_goat()
	
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
	rent_due.text = "PAID"
	rent_total.text = ""
	pay_rent.disabled = true
	pay_rent_label.visible = false

func _on_crops_pressed():
	player.sell_all_crops()
	update_units(player.units)
