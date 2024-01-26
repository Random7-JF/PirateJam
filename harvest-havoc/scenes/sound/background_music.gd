extends AudioStreamPlayer


@export var songs: Array[AudioStream]

# Called when the node enters the scene tree for the first time.
func _ready():
	play()

func _on_finished():
	stream = songs.pick_random()
	play()
