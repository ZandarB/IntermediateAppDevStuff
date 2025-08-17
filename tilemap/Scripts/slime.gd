extends Enemy

func _ready():
	speed = 40
	max_health = 5
	player_detection_radius = 150.0
	super._ready()
