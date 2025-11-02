extends Area2D

@export var rise_distance: float = 25
@export var rise_time: float = 0.5
@export var fall_time: float = 0.5
var target_player: Node2D = null

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

func _on_body_entered(body: Node2D) -> void:
	target_player = body
	if target_player.has_method("take_damage"):
		target_player.take_damage(10)
