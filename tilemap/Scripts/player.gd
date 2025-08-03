extends CharacterBody2D

var direction_x = 0.0
@export var speed = 150

func _process(_delta):
	get_input()
	apply_gravity()

	velocity.x = direction_x * speed
	move_and_slide()
	update_animation()

func get_input():
	direction_x = Input.get_axis("left", "right")

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -300 

func apply_gravity():
	velocity.y += 20 

func update_animation():
	if not is_on_floor():
		$AnimatedSprite2D.play("jump")
	elif direction_x != 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("default")

	$AnimatedSprite2D.flip_h = direction_x < 0

func _on_level_1_finish_body_entered(body: Node2D) -> void:
	call_deferred("_change_scene", "res://Scenes/level_2.tscn")

func _on_level_2_finish_body_entered(body: Node2D) -> void:
	call_deferred("_change_scene", "res://Scenes/level_3.tscn")

func _change_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)
