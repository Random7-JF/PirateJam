extends Timer

@export var grow_time: float = 5.0
@export var grow_variance: float = 2.0
@export var repeat_timer: bool = true

func _ready():
	setup_new_timer()

func setup_new_timer():
	if repeat_timer:
		wait_time = randf_range(grow_time - grow_variance, grow_time + grow_variance)
		start()
