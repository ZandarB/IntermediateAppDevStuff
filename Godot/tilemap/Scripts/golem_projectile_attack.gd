extends Area2D

var player: Node2D = null
const speed = 100
var direction := 1

func _process(delta):
	position.x += direction * speed * delta
	if not get_viewport_rect().has_point(global_position):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	print("Got here")
	if body.is_in_group("Player"):
			player = body
			player.take_damage(1)
			queue_free()
			
func set_direction(facing_right: bool) -> void:
	direction = 1 if facing_right else -1
	if $AnimatedSprite2D:
		$AnimatedSprite2D.flip_h = not facing_right
