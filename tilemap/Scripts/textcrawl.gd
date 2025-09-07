extends Label

var currrentLevel = "Level1"

var text1 = "Story Stuff Here"
var text2 = "Story2 Stuff Here"

func _ready():
	scroll_text(text1)

func levelSelect():
	if (currrentLevel == "Level1"):
		scroll_text(text1)
	elif (currrentLevel == "Level2"):
		scroll_text(text2)

func scroll_text(input_text:String) -> void:
	visible_characters = 0
	text = input_text
	
	for i in text.length():
		visible_characters += 1
		await get_tree().create_timer(0.05).timeout
