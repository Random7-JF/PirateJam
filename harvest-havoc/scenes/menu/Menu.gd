extends CanvasLayer
@export var level: PackedScene


func _on_play_button_pressed():
	get_tree().change_scene_to_packed(level)

func _on_quit_button_pressed():
	get_tree().quit()
