extends Enemy

func _ready():
	speed = 100
	max_health = 3
	player_detection_radius = 150.0
	super._ready()
