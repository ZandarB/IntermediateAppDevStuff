extends CanvasLayer

signal start_game

func show_message(text: String, auto_hide: bool = true):
	$Message.text = text
	$Message.show()
	if auto_hide:
		$MessageTimer.start()
	else:
		$MessageTimer.stop() 

func show_game_over():
	show_message("Game Over", true)
	await $MessageTimer.timeout

	show_message("Dodge The Creeps!", false)
	$StartButton.show()

func update_score(score):
	$ScoreLabel.text = str(score)

func _on_start_button_pressed() -> void:
	$StartButton.hide()
	
	$MessageTimer.start()
	
	start_game.emit()

func _on_message_timer_timeout() -> void:
	$Message.hide()
