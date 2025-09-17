extends Area2D
class_name Trap

@export var damage: int = 10
@export var damage_tickspeed: float = 0.0  

var damage_cooldown = 0.0

var ready_to_detect := false

func _ready() -> void:
	damage_cooldown = damage_tickspeed

func _physics_process(delta: float) -> void:
	if (damage_tickspeed > 0.0):
		damage_tickspeed -= delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player") and damage_tickspeed <= 0.0:
		body.take_damage(damage)
		damage_tickspeed = damage_cooldown
