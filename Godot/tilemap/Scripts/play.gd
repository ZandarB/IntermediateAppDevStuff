extends Button

var nextScene = "res://Scenes/level_1.tscn"

func _on_button_down() -> void:
	get_tree().change_scene_to_file(nextScene)
