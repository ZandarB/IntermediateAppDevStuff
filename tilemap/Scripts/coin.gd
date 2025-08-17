extends Area2D
@export var value := 100

func _ready():
	$AnimatedSprite2D.play("default")

func _on_body_entered(body: Node2D) -> void:
	if body.name == ("Player"):
		var root = get_tree().get_current_scene()
		var score_manager = root.get_node_or_null("UI")
		if score_manager:
			score_manager.add_score(value)
		queue_free()
