extends Area2D 

@export var speed = 50
@export var hit_stun_duration := 1.00
var hit_stun_time := 0.0

var direction := 1
var velocity
var health: int = 5
var is_dead := false

func _physics_process(delta):
	if not is_dead:
		if hit_stun_time <= 0:
			position.x += direction * speed * delta
			if not $FloorRay.is_colliding() or $WallRay.is_colliding():
				direction *= -1
				$AnimatedSprite2D.flip_h = direction < 0
				flip_rays()
		else:
			hit_stun_time -= delta

func _process(_delta: float) -> void:
	check_death()

func _ready():
	$AnimatedSprite2D.play("default")

func _on_body_entered(_body: Node2D) -> void:
	if health > 0 and not is_dead:
		health -= 1
		hit_stun_time = hit_stun_duration
		var tween: Tween = create_tween()
		tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 0.0)
		tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 0.1).set_delay(0.2)
		$AnimatedSprite2D.play("hit")

func check_death() -> void:
	if health <= 0 and not is_dead:
		die()

func flip_rays():
	$WallRay.position.x = abs($WallRay.position.x) * direction
	$FloorRay.position.x = abs($FloorRay.position.x) * direction


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_dead:
		return
	if (health > 0):
		$AnimatedSprite2D.play("default")

func die() -> void:
	is_dead = true
	speed = 0
	$AnimatedSprite2D.play("dead")
