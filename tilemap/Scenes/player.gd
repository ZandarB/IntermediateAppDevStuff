extends CharacterBody2D

var direction_x = 0.0

@export var speed = 150

func _process(delta):
	get_input()
	apply_gravity()
	
	velocity.x = direction_x * speed
	move_and_slide()
		
func get_input():
	direction_x = Input.get_axis("left", "right")

	if Input.is_action_just_pressed("jump"):
		velocity.y = -400 # Adjust the jump height as needed

func apply_gravity():
	velocity.y += 20


func _on_level_1_finish_body_entered(body: Node2D) -> void:
		get_tree().change_scene_to_file("res://Scenes/level_2.tscn")


func _on_level_2_finish_body_entered(body: Node2D) -> void:
		get_tree().change_scene_to_file("res://Scenes/level_3.tscn")
