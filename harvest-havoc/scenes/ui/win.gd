extends Control

@export var shop_ui: Control

# Called when the node enters the scene tree for the first time.
func _ready():
	shop_ui.connect("paid_rent", win)

func win():
	visible = true
	shop_ui.visible = false

func _on_conintue_button_pressed():
	visible = false
	shop_ui.visible = true


func _on_exit_button_pressed():
	get_tree().quit()
