extends Label

var currentScene = ""
var nextScene = ""

var text1 = "Story Stuff Here"
var text2 = "Story2 Stuff Here"

var is_scrolling = false
var full_text = ""

func _ready():
	currentScene = Global.current_level
	print(currentScene)

	if currentScene == "Level1":
		nextScene = "level_2"
		await scroll_text(text1)
	elif currentScene == "Level2":
		nextScene = "level_3"
		await scroll_text(text2)

	await wait_for_space_press()
	change_to_next_scene()


func scroll_text(input_text: String) -> void:
	full_text = input_text
	text = ""
	is_scrolling = true

	for i in range(input_text.length()):
		if Input.is_action_just_pressed("ui_accept"):
			text = full_text
			is_scrolling = false
			return
		
		text = input_text.substr(0, i + 1)
		await get_tree().create_timer(0.05).timeout

	is_scrolling = false


func wait_for_space_press() -> void:
	print("Waiting for SPACE press...")
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept"):
			if is_scrolling:
				text = full_text
				is_scrolling = false
			else:
				break


func change_to_next_scene():
	var scene_path = "res://Scenes/" + nextScene + ".tscn"
	get_tree().change_scene_to_file(scene_path)
