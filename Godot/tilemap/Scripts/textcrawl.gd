extends Label

var currentScene = ""
var nextScene = ""

var text1 = "I was gonna do a story here, but I couldn't think of one, so its a mini dev-log. 
All the 3 levels I made are the sum of 2 levels each save for level 3. 
Anyway I like DOOM so thats where the screen melt comes from, and this story read too. 
Don't know why I did this it was probably a waste of time, looks cool thought. Anyway, next level is some dungeon crawling. Good Luck!"
var text2 = "It's ya boy, back again with another mini dev-log, this next level is the most unique and probably the most difficult by a long shot.
Probably a bit too difficult if you ask me, mostly because of parkour, but you can retry if you die anyway. 
I thought it was fun to build and learn how to do, but it might be different having to play through the whole level again if you die.
And a new enemy at the end ooooh exciting
Anyway, enjoy climbing the tower of hell (name is forever a work in progress, tower of babel is probably better so go with that)."

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
