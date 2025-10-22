extends Enemy

enum State { PATROLLING, CHASING, ATTACKING, STUNNED, DEAD, UPGRADING}
var current_state = State.PATROLLING

var target_player: Node2D = null
var player_in_attack_range = false
var attack_in_progress = false
var stop_distance = 1.0
var attack_cooldown = 0.0
var health_threshold = 10
var armour_broken = false
var armour_regen_time = 10.0
var upgrading_in_progress = false
var stun_duration = 0.0
var last_damage_frame = -1
var attack_damage_frames = {
	"attack1": [5, 6, 7, 8, 9],
	"attack2": [5, 6],
	"attack3": [2],
	"armoredAttack1": [3, 4],
	"armoredAttack2": [4, 5],
	"armoredAttack3": [4, 5, 6]
}
var current_attack = ""
var attack_hit_already = false
var regeneration_in_progress = false


func _ready():
	speed = 50
	max_health = 20
	score_value = 1000
	player_detection_radius = 15
	
	super._ready()
	
	if armour_broken:
		$AnimatedSprite2D.play("move")
	else:
		$AnimatedSprite2D.play("armoredMove")

func _physics_process(delta):
	if is_dead:
		current_state = State.DEAD
		return
		
	if attack_cooldown > 0.0:
		attack_cooldown -= delta
	if stun_duration > 0.0:
		stun_duration -= delta
	match current_state:
		State.PATROLLING:
			if armour_broken:
				if armour_regen_time > 0.0:
					armour_regen_time -= delta
				elif not regeneration_in_progress:
					regeneration_in_progress = true
					await regenerate()
			patrol(delta)
			
		State.CHASING:
			chase_player(delta)
		State.ATTACKING:
			attack()
		State.STUNNED:
			stun()
		State.DEAD:
			pass
		State.UPGRADING:
			if upgrading_in_progress:
				pass
			else:
				armourBreak()
			
func _on_player_detection_body_entered(body):
	if body.is_in_group("Player") and !is_dead:
		target_player = body
		current_state = State.CHASING

func _on_player_detection_body_exited(body):
	if body.is_in_group("Player") and !is_dead:
		target_player = null
		current_state = State.PATROLLING

func _on_attack_hitbox_body_entered(body):
	if body.is_in_group("Player") and !is_dead and current_state != State.ATTACKING:
		player_in_attack_range = true
		current_state = State.ATTACKING

func _on_attack_hitbox_body_exited(body):
	if body.is_in_group("Player") and !is_dead:
		player_in_attack_range = false


func attack() -> void:
	if attack_in_progress or is_dead or attack_cooldown > 0.0 or current_state != State.ATTACKING:
		return
	
	attack_in_progress = true
	speed = 0
	last_damage_frame = -1
	attack_hit_already = false

	var rng = RandomNumberGenerator.new()
	if armour_broken:
		current_attack = "attack1"
	else:
		current_attack = "armoredAttack1"

	if has_method(current_attack):
		await call_deferred(current_attack)
		await $AnimatedSprite2D.animation_finished
		attack_in_progress = false
		attack_cooldown = 2.0
		if armour_broken:
			speed = 100
		else:
			speed = 50
		if target_player != null and is_instance_valid(target_player):
			if player_in_attack_range:
				current_state = State.ATTACKING
			else:
				current_state = State.CHASING
				if armour_broken:
					$AnimatedSprite2D.play("move")
				else:
					$AnimatedSprite2D.play("armoredMove")
		else:
			current_state = State.PATROLLING

		
func _on_attack_frame_changed():
	var frame = $AnimatedSprite2D.frame
	var projectile_attack = preload("res://Scenes/golem_projectile_attack.tscn").instantiate()
	var ground_attack =  preload("res://Scenes/golem_ground_attack.tscn").instantiate()
	if current_attack == "":
		return
	if frame in attack_damage_frames[current_attack] and frame != last_damage_frame and !attack_hit_already:
		if current_attack == "armoredAttack3":
			get_tree().current_scene.add_child(projectile_attack)

func on_hit():
	if !iframes:
		stun_duration = 0.8
		speed = 0
		current_state = State.STUNNED
		
		if attack_in_progress:
			attack_in_progress = false

		if health <= health_threshold and !armour_broken:
			iframes = true
			print("Upgrading")
			current_state = State.UPGRADING
		if health <= 0:
			is_dead = true
			die()
		

func _play_hit_animation() -> void:
	if iframes or current_state == State.UPGRADING or is_dead or upgrading_in_progress:
		return
		
	var tween := create_tween()
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 0.0)
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 0.1).set_delay(0.2)
	
	if armour_broken:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		$AnimatedSprite2D.play("hit2")
	else:
		$AnimatedSprite2D.play("armoredHit")
	
	await get_tree().create_timer(0.8).timeout
	
	if health > 0 and armour_broken:
		$AnimatedSprite2D.play("move")
	elif health > 0 and !armour_broken:
		$AnimatedSprite2D.play("armoredMove")

func chase_player(delta: float) -> void:
	if target_player != null:
		var distance_x = target_player.global_position.x - global_position.x
		if abs(distance_x) > stop_distance:
			var new_direction = sign(distance_x)
			if direction != new_direction:
				direction = new_direction
				$AnimatedSprite2D.flip_h = direction < 0
				flip_rays()
			position.x += direction * speed * delta
			if armour_broken:
				if $AnimatedSprite2D.animation != "move":
					$AnimatedSprite2D.play("move")
			else:
				if $AnimatedSprite2D.animation != "armoredMove":
					$AnimatedSprite2D.play("armoredMove")
		else:
			if armour_broken:
				if $AnimatedSprite2D.animation != "move":
					$AnimatedSprite2D.play("move")
			else:
				if $AnimatedSprite2D.animation != "armoredMove":
					$AnimatedSprite2D.play("armoredMove")

func armourBreak():
	armour_broken = true
	upgrading_in_progress = true
	iframes = true
	speed = 0
	
	print ("armour broke")

	$AnimatedSprite2D.play("armourBreak")
	await get_tree().create_timer(1.2).timeout #Using a timer instead of animation_finished because the FSM switches -
	#- the animation before its done and it switches to one that loops so the animation_finished is never true -
	#- 1.2 second because 5fps with 5 frames = 1 sec, + a little more just because
	
	print ("Animation finished")

	iframes = false
	upgrading_in_progress = false
	attack_in_progress = false
	current_attack = ""
	attack_hit_already = false

	# Reset speed & state
	speed = 100
	if player_in_attack_range:
		current_state = State.ATTACKING
	else:
		current_state = State.CHASING
	
	upgrading_in_progress = false
	
	
func regenerate():
	print("regenning")
	regeneration_in_progress = true
	armour_regen_time = 10.0
	speed = 0
	health = 20
	iframes = true

	attack_in_progress = false
	current_attack = ""
	attack_hit_already = false

	armour_broken = false
	$AnimatedSprite2D.play("armourRegen")
	await get_tree().create_timer(2.2).timeout #Same reason as before, 2.2 seconds because 5fps with 11 frames.
	$AnimatedSprite2D.play("armoredMove")

	iframes = false
	speed = 50
	regeneration_in_progress = false

	if target_player != null and is_instance_valid(target_player):
		if player_in_attack_range:
			current_state = State.ATTACKING
			print ("attacking")
		else:
			current_state = State.CHASING
			print ("chasing")
	else:
		current_state = State.PATROLLING
		print ("patrolling")

func stun():
	if stun_duration <= 0.0:
		if current_state == State.STUNNED and !is_dead and !upgrading_in_progress:
			if player_in_attack_range:
				current_state = State.ATTACKING
			else:
				current_state = State.CHASING
			if armour_broken:
				speed = 100
			else:
				speed = 50
				

func armoredAttack1() -> void:
	if not is_instance_valid(target_player):
		current_state = State.PATROLLING
		attack_in_progress = false
		return

	var ground_attack_scene = preload("res://Scenes/golem_ground_attack.tscn")
	var ground_attack = ground_attack_scene.instantiate()

	var start_pos = target_player.global_position
	var end_pos = start_pos + Vector2(0, 1000) 

	var ray_params = PhysicsRayQueryParameters2D.new()
	ray_params.from = start_pos
	ray_params.to = end_pos
	ray_params.exclude = [self, target_player]

	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(ray_params)

	if result:
		ground_attack.global_position = result.position
	else:
		ground_attack.global_position = start_pos + Vector2(0, 50)

	get_tree().current_scene.add_child(ground_attack)
	$AnimatedSprite2D.play("armoredAttack1")
	
func attack1() -> void:
	if not is_instance_valid(target_player):
		current_state = State.PATROLLING
		attack_in_progress = false
		return

	var ground_attack_scene = preload("res://Scenes/golem_ground_attack.tscn")
	var ground_attack = ground_attack_scene.instantiate()

	var start_pos = target_player.global_position
	var end_pos = start_pos + Vector2(0, 1000) 

	var ray_params = PhysicsRayQueryParameters2D.new()
	ray_params.from = start_pos
	ray_params.to = end_pos
	ray_params.exclude = [self, target_player]

	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(ray_params)

	if result:
		ground_attack.global_position = result.position
	else:
		ground_attack.global_position = start_pos + Vector2(0, 50)

	get_tree().current_scene.add_child(ground_attack)
	$AnimatedSprite2D.play("attack1")
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play("attackReset")
	await $AnimatedSprite2D.animation_finished
	attack_in_progress = false
