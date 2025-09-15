extends Enemy

func _ready():
	speed = 40
	max_health = 5
	score_value = 250
	player_detection_radius = 15
	super._ready()

var chasing := false
var player_in_attack_range := false

var stop_distance := 1.0
 
var attack_cooldown := 2.0 
var attack_timer := 0.0
var is_attacking = false
var attack_canceled = false

var target_player: Node2D = null

@onready var attack_hitbox = $AttackHitbox

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if chasing and target_player:
		chase_player(delta)
	else:
		super._physics_process(delta)
	
	if attack_timer > 0.0:
		attack_timer -= delta
	if hit_stun_time > 0.0:
		hit_stun_time -= delta

	if player_in_attack_range and attack_timer <= 0.0 and hit_stun_time <= 0.0:
		attack()

func on_hit():
	if is_attacking:
		attack_canceled = true 
		is_attacking = false
		speed = 40
		$AnimatedSprite2D.play("default")

func attack():
	is_attacking = true
	attack_canceled = false
	chasing = false
	
	await get_tree().create_timer(0.5).timeout
	speed = 0

	$AnimatedSprite2D.play("attack")
	$EffectAnimatedSprite2D.play("effect")
	attack_timer = attack_cooldown
	is_attacking = false
	
	if player_in_attack_range and is_instance_valid(target_player):
		target_player.take_damage(1)
	
	await get_tree().create_timer(1.0).timeout
	$AnimatedSprite2D.play("default")
	speed = 40
	
	if is_instance_valid(target_player) and chasing == false and player_in_attack_range == false:
		return
	
	if is_instance_valid(target_player):
		chasing = true

func chase_player(delta: float) -> void:
	var distance_x = target_player.global_position.x - global_position.x
	if abs(distance_x) > stop_distance:
		var dir = sign(distance_x)

		super.flip_rays()

		if should_flip_direction():
			if $AnimatedSprite2D.animation != "idle":
				$AnimatedSprite2D.play("idle")
			speed = 0
		else:
			speed = 40
			direction = dir
			position.x += direction * speed * delta
			$AnimatedSprite2D.flip_h = direction < 0
			$PlayerDetection.position.x = player_detection_radius * 4 * direction
			$PlayerDetection.scale.x = player_detection_radius / 2 * direction
	else:
		speed = 0
		if $AnimatedSprite2D.animation != "idle":
			$AnimatedSprite2D.play("idle")

func _on_player_detection_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.is_in_group("Player"):
		target_player = body
		chasing = true

func _on_player_detection_body_exited(body: Node2D) -> void:
	if is_dead:
		return
	if body.is_in_group("Player"):
		target_player = null
		chasing = false

func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and is_dead == false:
		player_in_attack_range = true
		speed = 0
		chasing = false

func _on_attack_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") and is_dead == false:
		player_in_attack_range = false
		speed = 40
		$AnimatedSprite2D.play("default")
		$AnimatedSprite2D.flip_h = direction < 0
		$PlayerDetection.scale.x = player_detection_radius / 2 * direction
		$PlayerDetection.position.x = player_detection_radius * 4 * direction

func _on_effect_animated_sprite_2d_animation_finished() -> void:
	if player_in_attack_range == true and is_dead == false:
		attack()
	elif is_dead == false:
		$EffectAnimatedSprite2D.play("default")
