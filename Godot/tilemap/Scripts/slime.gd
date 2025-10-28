extends Enemy

enum State { PATROLLING, CHASING, ATTACKING, STUNNED, DEAD }
var current_state = State.PATROLLING

var target_player: Node2D = null
var player_in_attack_range = false
var is_attacking = false
var stop_distance = 1.0
var attack_cooldown = 0.0
var attack_in_progress = false

func _ready():
	speed = 100
	max_health = 3
	score_value = 100 
	player_detection_radius = 10
	super._ready()

func _physics_process(delta):
	print(current_state)
	if is_dead:
		current_state = State.DEAD
		return
		
	if attack_cooldown > 0.0:
		attack_cooldown -= delta

	match current_state:
		State.PATROLLING:
			speed = 40
			patrol(delta)
		State.CHASING:
			chase_player(delta)
		State.ATTACKING:
			attack()
		State.STUNNED:
			pass
		State.DEAD:
			pass

func _on_player_detection_body_entered(body):
	if body.is_in_group("Player") and !is_dead:
		target_player = body
		current_state = State.CHASING

func _on_player_detection_body_exited(body):
	if body.is_in_group("Player") and !is_dead:
		print("got here")
		target_player = null
		speed = 100
		current_state = State.PATROLLING

func _on_attack_hitbox_body_entered(body):
	if body.is_in_group("Player") and !is_dead and current_state != State.ATTACKING:
		player_in_attack_range = true
		current_state = State.ATTACKING

func _on_attack_hitbox_body_exited(body):
	if body.is_in_group("Player") and !is_dead:
		player_in_attack_range = false


func attack() -> void:
	if attack_in_progress or is_dead or attack_cooldown > 0:
		return

	attack_in_progress = true
	speed = 0


	$AnimatedSprite2D.play("attack")
	if player_in_attack_range and target_player != null:
		if target_player.has_method("take_damage"):
			target_player.take_damage(10)
			$EffectAnimatedSprite2D.play("effect")
			attack_cooldown = 1.5

	# Wait for attack animation to finish
	await get_tree().create_timer(1.0).timeout

	if is_dead:
		attack_in_progress = false
		return

	attack_in_progress = false
	speed = 40

	if player_in_attack_range:
		current_state = State.ATTACKING
		$AnimatedSprite2D.play("idle")
	elif target_player != null:
		current_state = State.CHASING
		$AnimatedSprite2D.play("move")
	else:
		current_state = State.PATROLLING
		$AnimatedSprite2D.play("move")
func on_hit():
	if is_attacking:
		is_attacking = false
		current_state = State.STUNNED
		speed = 0
		$AnimatedSprite2D.play("hit")
		if health <= 0:
			is_dead = true
			current_state = State.DEAD
			$AnimatedSprite2D.play("dead")
		else:
			pass

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
