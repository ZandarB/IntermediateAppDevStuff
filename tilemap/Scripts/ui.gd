extends Node

var scoreLabel: Label
var healthLabel: Label


func _ready():
	if has_node("Score"):
		scoreLabel = $Score
		add_score(0)

func add_score(amount: int) -> void:
	Global.score += amount
	if scoreLabel:
		scoreLabel.text = "Score: " + str(Global.score)

func update_health() -> void:
	if healthLabel:
		healthLabel.text = "Health: " + str(Global.health)
