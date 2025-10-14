extends Area2D

var player: Node2D = null
const speed = 100
var direction := 1


func _process(delta):
		position.x += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	print("Got here")
	if body.is_in_group("Player"):
			player = body
			player.take_damage(1)
			queue_free()
			
