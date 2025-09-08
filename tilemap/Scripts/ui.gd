extends Node

var label: Label

func _ready():
	if has_node("Score"):
		label = $Score
		update_score_label()

func add_score(amount: int) -> void:
	Global.score += amount
	update_score_label()

func update_score_label() -> void:
	if label:
		label.text = "Score: " + str(Global.score)

func healthThingy():
	pass
