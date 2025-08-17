extends Area2D
class_name Enemy

@export var speed := 50
@export var max_health := 5
@export var player_detection_radius := 200.0

var hit_stun_duration := 1.0

var health: int
var is_dead := false
var hit_stun_time := 0.0
var direction := 1

func _ready() -> void:
	health = max_health
	$AnimatedSprite2D.play("default")
	flip_rays()

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if hit_stun_time > 0:
		hit_stun_time -= delta
		return

	patrol(delta)

func patrol(delta: float) -> void:
	position.x += direction * speed * delta

	if should_flip_direction():
		direction *= -1
		$AnimatedSprite2D.flip_h = direction < 0
		flip_rays()

func should_flip_direction() -> bool:
	return (not $FloorRay.is_colliding()) or $WallRay.is_colliding()

func flip_rays() -> void:
	$WallRay.position.x = abs($WallRay.position.x) * direction
	$FloorRay.position.x = abs($FloorRay.position.x) * direction

func _on_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.name == ("Player"):
		apply_damage(1)

func apply_damage(amount: int) -> void:
	health -= amount
	hit_stun_time = hit_stun_duration
	_play_hit_animation()

	if health <= 0:
		die()

func _play_hit_animation() -> void:
	var tween := create_tween()
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 0.0)
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 0.1).set_delay(0.2)
	$AnimatedSprite2D.play("hit")

func die() -> void:
	is_dead = true
	speed = 0
	$AnimatedSprite2D.play("dead")

func _on_animated_sprite_2d_animation_finished() -> void:
	if not is_dead:
		$AnimatedSprite2D.play("default")
