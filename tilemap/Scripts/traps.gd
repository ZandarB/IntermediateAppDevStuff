extends Area2D
class_name Trap

@export var damage: int = 10
@export var detect_delay: float = 0.0  # optional delay before detection starts

var ready_to_detect := false

func _ready() -> void:
	if detect_delay > 0:
		await get_tree().create_timer(detect_delay).timeout
		_enable_detection()
	else:
		_enable_detection()

func _enable_detection() -> void:
	ready_to_detect = true

func _on_body_entered(body: Node) -> void:
	if not ready_to_detect:
		return
	
	if body.is_in_group("Player"):
		body.take_damage(damage)
		print("Player hit a trap! Damage:", damage)
