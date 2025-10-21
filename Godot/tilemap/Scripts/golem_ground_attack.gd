extends Area2D

@export var rise_distance: float = 25
@export var rise_time: float = 0.5
@export var fall_time: float = 0.5

var original_position: Vector2

func _ready():
	original_position = $CollisionShape2D.position
	$AnimatedSprite2D.play("default")
	await get_tree().create_timer(0.5).timeout
	spawn_attack()

func spawn_attack() -> void:
	var tween = create_tween()
	

	tween.tween_property($CollisionShape2D, "position:y", original_position.y - rise_distance, rise_time)
	await tween.finished
	
	tween = create_tween()
	tween.tween_property($CollisionShape2D, "position:y", original_position.y, fall_time)
	await tween.finished

	queue_free()
