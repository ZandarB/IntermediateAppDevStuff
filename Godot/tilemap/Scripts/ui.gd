extends Node

var scoreLabel: Label
var healthLabel: Label


func _ready():
	if has_node("Score"):
		scoreLabel = $Score
		update_score(0)
	if has_node("Health"):
		healthLabel = $Health


func update_score(amount: int) -> void:
	Global.score += amount
	scoreLabel.text = "Score: " + str(Global.score)

func update_health() -> void:
	healthLabel.text = "Health: " + str(Global.health)
