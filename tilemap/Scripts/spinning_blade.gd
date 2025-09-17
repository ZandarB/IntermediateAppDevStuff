extends Trap

func _ready() -> void:
	damage = 5
	damage_tickspeed = 0.5
	$AnimatedSprite2D.play("default")
