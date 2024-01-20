extends Node

@export var tick_in_seconds:int = 20

#Signal for calling growth on weeds / crops
signal lifetime_tick

@onready var game_timer: Timer = $GameTimer

func _ready():
	start_game_timer()

func _on_game_timer_timeout():
	print("emit lifetime")
	emit_signal("lifetime_tick")
	start_game_timer()
	
func start_game_timer():
	print("Game Tick")
	game_timer.wait_time = tick_in_seconds
	game_timer.start()
