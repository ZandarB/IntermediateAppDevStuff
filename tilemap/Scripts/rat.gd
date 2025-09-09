extends Enemy

func _ready():
	speed = 100
	max_health = 3
	score_value = 100 
	player_detection_radius = 10
	super._ready()

func _on_player_detection_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.is_in_group("Player"):
		print("I see the player")

func _on_player_detection_body_exited(body: Node2D) -> void:
	if is_dead:
		return
	if body.is_in_group("Player"):
		print("I can't see the player")
