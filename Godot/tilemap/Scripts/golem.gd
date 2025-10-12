extends Enemy

enum State { PATROLLING, CHASING, ATTACKING, STUNNED, DEAD, UPGRADING}
var current_state = State.PATROLLING

var target_player: Node2D = null
var player_in_attack_range = false
var is_attacking = false
var stop_distance = 1.0
var attack_cooldown = 0.0
var attack_in_progress = false
var health_threshold = 10
var armour_broken = false
var armour_regen_time = 10.0
var upgrading_in_progress = false

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
			pass
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
		if current_state == State.ATTACKING:
			current_state = State.CHASING

func attack() -> void:
	if attack_in_progress or is_dead or attack_cooldown > 0.0 or current_state == State.UPGRADING:
		return

	attack_in_progress = true
	is_attacking = true
	speed = 0
	last_damage_frame = -1
	attack_hit_already = false
	
	if !player_in_attack_range or !is_instance_valid(target_player):
		attack_in_progress = false
		is_attacking = false
		current_state = State.CHASING
		return
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var atk_num = rng.randi_range(1, 3)
	
	if armour_broken:
		if current_attack == "attack1":
			$AnimatedSprite2D.play("attackReset")
			await $AnimatedSprite2D.animation_finished
		current_attack = "attack%d" % atk_num
		$AnimatedSprite2D.play(current_attack)
		await $AnimatedSprite2D.animation_finished
	else:
		current_attack = "armoredAttack%d" % atk_num
		$AnimatedSprite2D.play(current_attack)

	if not $AnimatedSprite2D.is_connected("frame_changed", Callable(self, "_on_attack_frame_changed")):
		$AnimatedSprite2D.connect("frame_changed", Callable(self, "_on_attack_frame_changed"))

	while $AnimatedSprite2D.is_playing():
		await get_tree().process_frame
		if !player_in_attack_range or !is_instance_valid(target_player):
			if armour_broken:
				$AnimatedSprite2D.play("move")
			else:
				$AnimatedSprite2D.play("armoredMove")

			
			current_state = State.CHASING
			break

	attack_in_progress = false
	is_attacking = false
	attack_cooldown = 2.0
	if armour_broken:
		speed = 100
	else:
		speed = 50
	
	if !attack_in_progress:
		if armour_broken:
			$AnimatedSprite2D.play("move")
		else:
			$AnimatedSprite2D.play("armoredMove")

func _on_attack_frame_changed():
	if current_attack == "":
		return
	var frame = $AnimatedSprite2D.frame
	if frame in attack_damage_frames[current_attack] and frame != last_damage_frame and !attack_hit_already:
		if player_in_attack_range and is_instance_valid(target_player):
			target_player.take_damage(1)
			last_damage_frame = frame
			attack_hit_already = true
			$EffectAnimatedSprite2D.play(current_attack)
			await $EffectAnimatedSprite2D.animation_finished
			$EffectAnimatedSprite2D.play("default")

func on_hit():
	if !iframes:
		if is_attacking:
			is_attacking = false
			current_state = State.STUNNED
			speed = 0

		if health <= health_threshold and !armour_broken:
			speed = 0
			iframes = true
			print("Upgrading")
			upgrading_in_progress = true
			current_state = State.UPGRADING
			armourBreak()
		

func _play_hit_animation() -> void:
	if iframes or current_state == State.UPGRADING or is_dead or upgrading_in_progress:
		return
		
	var tween := create_tween()
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 0.0)
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 0.1).set_delay(0.2)
	
	if armour_broken:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var hit_num = rng.randi_range(1, 2)
		$AnimatedSprite2D.play("hit%d" % hit_num)
	else:
		$AnimatedSprite2D.play("armoredHit")
	
	await get_tree().create_timer(0.8).timeout
	
	if health > 0 and armour_broken:
		$AnimatedSprite2D.play("move")
	elif health > 0 and !armour_broken:
		print("Got here")
		$AnimatedSprite2D.play("armoredMove")

func chase_player(delta: float) -> void:
	var distance_x = target_player.global_position.x - global_position.x
	if abs(distance_x) > stop_distance:
		var dir = sign(distance_x)
		
		super.flip_rays()
		
		if should_flip_direction():
			if armour_broken:
				if $AnimatedSprite2D.animation != "move":
					$AnimatedSprite2D.play("move")
			else:
				if $AnimatedSprite2D.animation != "armoredMove":
					$AnimatedSprite2D.play("armoredMove")
			speed = 0
		else:
			if armour_broken:
				speed =  100
			else:
				speed = 50
				
			direction = dir
			position.x += direction * speed * delta
			$AnimatedSprite2D.flip_h = direction < 0
			$PlayerDetection.position.x = player_detection_radius * 4 * direction
			$PlayerDetection.scale.x = player_detection_radius / 2 * direction
	else:
		speed = 0
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
	is_attacking = false
	current_attack = ""
	attack_hit_already = false

	# Reset speed & state
	speed = 100
	current_state = State.CHASING
	

func regenerate():
	print("regenning")
	regeneration_in_progress = true
	armour_regen_time = 10.0
	speed = 0
	health = 20
	iframes = true

	attack_in_progress = false
	is_attacking = false
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


func _update_attack_hitbox():
	var hitbox_shape = $AttackHitbox/CollisionShape2D.shape

	match current_attack:
		"attack1", "armoredAttack1":
			# Normal melee swipe — short range
			$AttackHitbox.scale = Vector2(1.5, 3.0)

		"attack2", "armoredAttack2":
			# Ground AOE — wider and lower
			hitbox_shape.extents = Vector2(40, 10)
			$AttackHitbox.position = Vector2(0, 15)

		"attack3", "armoredAttack3":
			# Blast — disable melee hitbox, projectile handles this
			$AttackHitbox.monitoring = false
			#spawn_projectile()

func stun():
	$EffectAnimatedSprite2D.play("default")
