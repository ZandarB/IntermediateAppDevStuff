extends Area2D 

@export var speed = 50
var direction := -1
var velocity
var health: int = 5

func _physics_process(delta):
	position.x += direction * speed * delta
	if not $FloorRay.is_colliding() or $WallRay.is_colliding():
		direction *= -1
		$AnimatedSprite2D.flip_h = direction > 0
		flip_rays()

func _process(_delta: float) -> void:
	check_death()
	
	

func _ready():
	$AnimatedSprite2D.play("default")

func _on_body_entered(_body: Node2D) -> void:
	health -= 1
	var tween: Tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 0.0)
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 0.1).set_delay(0.2)


func check_death() -> void:
	if health <= 0:
		queue_free()

func flip_rays():
	# Flip ray positions based on direction
	$WallRay.position.x = abs($WallRay.position.x) * direction
	$FloorRay.position.x = abs($FloorRay.position.x) * direction
