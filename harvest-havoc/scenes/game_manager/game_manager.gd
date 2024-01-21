extends Node

@export var tick_in_seconds:int = 20

#Signal for calling growth on weeds / crops
signal lifetime_tick

@onready var game_timer: Timer = $GameTimer
var total_weeds_spawned: int = 0

func _ready():
	connect_weed_signals()
	start_game_timer()

func _on_game_timer_timeout():
	emit_signal("lifetime_tick")
	start_game_timer()
	
func start_game_timer():
	print("Game Tick")
	game_timer.wait_time = tick_in_seconds
	game_timer.start()

##################################################
## Weed related signals and functions           ##
##################################################
func connect_weed_signals():
	Events.connect("weed_spawned", weeds_spawned)
	Events.connect("weed_grew", weed_grew)
	
func weeds_spawned():
	total_weeds_spawned += 1
	print("Weed spawned")

func weed_grew():
	pass
