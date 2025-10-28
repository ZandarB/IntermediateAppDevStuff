extends Node2D

func _ready() -> void:
	$Panel/ScoreLabel.text = "Score:" + str(Global.score)
	$Panel/ScoreLabel.text = "Score: " + str(Global.score)

func _on_back_to_menu_button_button_down() -> void:
	Global.health = 100
	Global.score = 0
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
