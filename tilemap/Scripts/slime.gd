extends Enemy

func _ready():
	speed = 40
	max_health = 5
	score_value = 250
	player_detection_radius = 15
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
