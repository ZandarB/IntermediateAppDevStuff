extends Enemy

var target_player: Node2D = null
var player_in_range = false
enum State { IDLE, PATROLLING, RUNNING_AWAY }
var state: State = State.PATROLLING
var is_running_away = false


func _ready():
	speed = 100
	max_health = 3
	score_value = 100 
	player_detection_radius = 10
	super._ready()

func _physics_process(delta: float) -> void:
	if state == State.RUNNING_AWAY:
		allow_flipping = false
	else:
		allow_flipping = true

	if hit_stun_time > 0.0:
		hit_stun_time = max(hit_stun_time - delta, 0)
		return

	match state:
		State.PATROLLING:
			patrol(delta)
		State.RUNNING_AWAY:
			run_away(delta)
		State.IDLE:
			if $AnimatedSprite2D.animation != "idle":
				$AnimatedSprite2D.play("idle")

func _on_player_detection_body_entered(body: Node2D) -> void:
	if is_dead: return
	if body.is_in_group("Player"):
		target_player = body
		state = State.RUNNING_AWAY

func _on_player_detection_body_exited(body: Node2D) -> void:
	if is_dead: return
	if body.is_in_group("Player"):
		target_player = null
		state = State.PATROLLING
		$PlayerDetection.position.x = abs($PlayerDetection.position.x)
		speed = 100

func run_away(delta: float) -> void:
	if not is_instance_valid(target_player):
		state = State.PATROLLING
		return

	var distance_x = target_player.global_position.x - global_position.x
	direction = -sign(distance_x)

	if $FloorRay.is_colliding():
		# Move away from player
		speed = 100
		position.x += direction * speed * delta

		# Flip sprite while moving
		$AnimatedSprite2D.flip_h = direction < 0
		
		# Move detection **behind** the enemy
		$PlayerDetection.position.x = -abs($PlayerDetection.position.x) * direction
		$FloorRay.position.x = abs($FloorRay.position.x) * direction

		if $AnimatedSprite2D.animation != "move":
			$AnimatedSprite2D.play("move")
	else:
		# Stop at edge and prevent flipping
		speed = 0
		if $AnimatedSprite2D.animation != "idle":
			$AnimatedSprite2D.play("idle")
		
func on_hit():
	speed = 0
	await $AnimatedSprite2D.animation_finished
	if health <= 0:
		is_dead = true
	else:
		speed = 100
