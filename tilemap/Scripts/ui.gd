extends Node

var score = 0;

func add_score(amount: int) -> void:
	score += amount
	var label = $Score 
	if label:
		label.text = "Score: " + str(score)

func healthThingy():
	pass
