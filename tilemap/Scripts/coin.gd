extends Area2D
@export var value := 100

func _ready():
	$AnimatedSprite2D.play("default")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player": 
		body.add_score(value)
		queue_free()
