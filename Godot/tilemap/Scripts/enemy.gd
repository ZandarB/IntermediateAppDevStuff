extends Area2D
class_name Enemy

@export var speed: int
@export var max_health: int
@export var player_detection_radius: float
@export var score_value: int

@onready var player_detection = $PlayerDetection
var hit_stun_duration := 0.8

var health: int
var is_dead := false
var hit_stun_time := 0.0
var direction := 1
var vertical_offset: float = 1
var attacking_area: Area2D = null
var dead_is_playing = false
var allow_flipping = true
var iframes = false

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))
	health = max_health
	$AnimatedSprite2D.play("move")
	flip_rays()

func _physics_process(delta: float) -> void:
	if is_dead && dead_is_playing == false:
		$AnimatedSprite2D.play("dead")
		dead_is_playing = true

	flip_rays()
	if hit_stun_time > 0.0 or iframes:
		hit_stun_time = max(hit_stun_time - delta, 0)
		speed = 0
		return

func patrol(delta: float) -> void:
	if allow_flipping:
		if should_flip_direction():
			direction *= -1
			$AnimatedSprite2D.flip_h = direction < 0
			flip_rays()
		position.x += direction * speed * delta


func should_flip_direction() -> bool:
	if allow_flipping:
		return (not $FloorRay.is_colliding()) or $WallRay.is_colliding()
	return false
	

func flip_rays() -> void:
	$WallRay.position.x = abs($WallRay.position.x) * direction
	$FloorRay.position.x = abs($FloorRay.position.x) * direction
	
	$WallRay.target_position.x = abs($WallRay.target_position.x) * direction

	$PlayerDetection.scale.x = player_detection_radius / 2 * direction
	$PlayerDetection.position.x = player_detection_radius * 4 * direction

func apply_damage(amount: int) -> void:
	if is_dead or iframes:
		return

	health -= amount
	hit_stun_time = hit_stun_duration
	_play_hit_animation()
	
	on_hit()
	
	if health <= 0:
		die()
	
func on_hit():
	pass

func _play_hit_animation() -> void:
	var tween := create_tween()
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 0.0)
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 0.1).set_delay(0.2)
	$AnimatedSprite2D.play("hit")
	await get_tree().create_timer(hit_stun_time).timeout
	if health > 0:
		$AnimatedSprite2D.play("move")


func _on_player_detection_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.is_in_group("Player"):
		pass

func _on_player_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		pass
	
func die():
	print("dead")
	is_dead = true
	$AnimatedSprite2D.play("dead")
	speed = 0
	var root = get_tree().get_current_scene()
	var score_manager = root.get_node_or_null("UI")
	if score_manager:
		score_manager.update_score(score_value)
