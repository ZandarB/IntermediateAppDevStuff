extends Area2D
class_name Enemy

@export var speed: int
@export var max_health: int
@export var player_detection_radius: float
@export var score_value: int

@onready var player_detection = $PlayerDetection
var hit_stun_duration := 1.0

var health: int
var is_dead := false
var hit_stun_time := 0.0
var direction := 1
var vertical_offset: float = 1

signal enemy_died(score_amount: int)


func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))
	health = max_health
	$AnimatedSprite2D.play("default")
	flip_rays()
	$PlayerDetection.connect("body_entered", Callable(self, "_on_player_detection_body_entered"))
	$PlayerDetection.connect("body_exited", Callable(self, "_on_player_detection_body_exited"))

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if hit_stun_time > 0:
		hit_stun_time -= delta
	else:
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
	
	$PlayerDetection.scale.x = player_detection_radius / 2 * direction
	$PlayerDetection.scale.y = player_detection_radius / 2 * direction
	$PlayerDetection.position.x = player_detection_radius * 4 * direction

func apply_damage(amount: int) -> void:
	if is_dead:
		return

	health -= amount
	hit_stun_time = hit_stun_duration
	_play_hit_animation()

	if health <= 0:
		is_dead = true
		$AnimatedSprite2D.play("dead")
		speed = 0
		
		var root = get_tree().get_current_scene()
		var score_manager = root.get_node_or_null("UI")
		if score_manager:
			score_manager.update_score(score_value)
			

func _play_hit_animation() -> void:
	var tween := create_tween()
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 0.0)
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 0.1).set_delay(0.2)
	$AnimatedSprite2D.play("hit")

func _on_area_entered(area: Area2D) -> void:
	print("entered area")
	if is_dead:
		return
	if area.name.begins_with("Attack"):
		apply_damage(1)
		print("hit")
		hit_stun_time = hit_stun_duration

func _on_player_detection_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.is_in_group("Player"):
		pass

func _on_player_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		pass
