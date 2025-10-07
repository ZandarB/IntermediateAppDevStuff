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


func _ready():
	speed = 50
	max_health = 20
	score_value = 1000
	player_detection_radius = 15
	
	super._ready()
	
	if !armour_broken:
		$AnimatedSprite2D.play("armoredMove")
	else:
		$AnimatedSprite2D.play("move")

func _physics_process(delta):
	if is_dead:
		current_state = State.DEAD
		return
		
	if attack_cooldown > 0.0:
		attack_cooldown -= delta
	match current_state:
		State.PATROLLING:
			speed = 50
			armour_regen_time -= delta
			if armour_regen_time <= 0.0:
				regenerate()
			patrol(delta)
			
		State.CHASING:
			chase_player(delta)
		State.ATTACKING:
			attack()
		State.STUNNED:
			pass
		State.DEAD:
			pass
		State.UPGRADING:
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
		if current_state == State.ATTACKING:
			current_state = State.CHASING

func attack() -> void:
	if attack_in_progress or is_dead or attack_cooldown > 0.0:
		return
	attack_in_progress = true
	is_attacking = true
	speed = 0
	last_damage_frame = -1
	attack_hit_already = false

	if !armour_broken:
		$AnimatedSprite2D.play("armoredIdle")
	else:
		$AnimatedSprite2D.play("idle1")

	await get_tree().create_timer(0.5).timeout 
	
	if player_in_attack_range and is_instance_valid(target_player):
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var atk_num = rng.randi_range(1, 3)
		
		if !armour_broken:
			current_attack = "armoredAttack%d" % atk_num
			$AnimatedSprite2D.play(current_attack)
			$EffectAnimatedSprite2D.play(current_attack)
		else:
			current_attack = "attack%d" % atk_num
			$AnimatedSprite2D.play(current_attack)
			$EffectAnimatedSprite2D.play(current_attack)
	if not $AnimatedSprite2D.is_connected("frame_changed", Callable(self, "_on_attack_frame_changed")):
		$AnimatedSprite2D.connect("frame_changed", Callable(self, "_on_attack_frame_changed"))
	
	attack_in_progress = false
	is_attacking = false
	attack_cooldown = 3.0

func _on_attack_frame_changed():
	if current_attack == "":
		return
	var frame = $AnimatedSprite2D.frame
	if frame in attack_damage_frames[current_attack] and frame != last_damage_frame and !attack_hit_already:
		if player_in_attack_range and is_instance_valid(target_player):
			#target_player.take_damage(20)
			last_damage_frame = frame
			attack_hit_already = true

func on_hit():
	if is_attacking:
		is_attacking = false
		current_state = State.STUNNED
		speed = 0
		$AnimatedSprite2D.play("hit")
		if health <= health_threshold and !armour_broken:
			current_state = State.UPGRADING
			return
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
			if $AnimatedSprite2D.animation != "idle1":
				$AnimatedSprite2D.play("idle1")
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
		if $AnimatedSprite2D.animation != "idle1":
			$AnimatedSprite2D.play("idle1")

func armourBreak():
	speed = 0
	iframes = true
	$AnimatedSprite2D.play("armourBreak")
	await $AnimatedSprite2D.animation_finished
	iframes = false
	speed = 100
	armour_broken = true

func regenerate():
	speed = 0
	health = 20
	iframes = true
	$AnimatedSprite2D.play("armourRegen")
	await $AnimatedSprite2D.animation_finished
	iframes = false
	speed = 50
	armour_broken = false

func is_invulnerable() -> bool:
	return iframes
	
func _play_hit_animation() -> void:
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
	
	if health > 0:
		$AnimatedSprite2D.play("move")
