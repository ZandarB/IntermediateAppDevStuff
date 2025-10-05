extends Enemy

var target_player: Node2D = null
var player_in_range = false
var is_running_away = false

func _ready():
	speed = 100
	max_health = 3
	score_value = 100 
	player_detection_radius = 10
	super._ready()

func _physics_process(delta: float) -> void:
	if is_dead:
		super._physics_process(delta)
		return
	if player_in_range == true:
		run_away(delta)
	else:
		super._physics_process(delta)

func _on_player_detection_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	else:
		target_player = body
		player_in_range = true
		
func _on_player_detection_body_exited(body: Node2D) -> void:
	if is_dead:
		return
	if body.is_in_group("Player"):
		print("I can't see the player")
		
func run_away(delta: float) -> void:
	allow_flipping = false
	if not is_instance_valid(target_player):
		is_running_away = false
		return

	var distance_x = target_player.global_position.x - global_position.x
	var to_player = sign(distance_x)
	direction = -to_player

	var no_floor_ahead = not $FloorRay.is_colliding()

	if no_floor_ahead:
		is_running_away = false
	else:
		is_running_away = true
		position.x += direction * speed * delta
		
	$AnimatedSprite2D.flip_h = direction < 0
	super.flip_rays()

	if hit_stun_time <= 0 and not is_dead:
		if is_running_away:
			if $AnimatedSprite2D.animation != "default":
				$AnimatedSprite2D.play("default")
		else:
			if $AnimatedSprite2D.animation != "idle":
				$AnimatedSprite2D.play("idle")
