extends CharacterBody2D

@export var speed = 150
@export var collision_reenable_offset = 4.0  # pixels below platform to re-enable collision
@onready var hitbox1 = $Attack1Hitbox
@onready var hitbox2 = $Attack2Hitbox
@onready var hitbox3 = $Attack3Hitbox

var dropping_through = false
var drop_platform_y = 0.0
var max_jumps = 2
var jumps_done = 0
var rng = RandomNumberGenerator.new()
var facing_left = false
var attacking = false
var direction_x = 0.0
var player_dead = false

var stun_time = 0.5
var stun_timer = 0.0

var attack_cooldown = 0.85
var attack_cooldown_left = 0.0

func _ready():
	$CollisionTimer.connect("timeout", Callable(self, "_on_collision_reset_timer_timeout"))
	$PlatformRay.enabled = true

func _physics_process(delta):
	if attack_cooldown_left > 0.0:
		attack_cooldown_left -= delta
		
	if player_dead == true:
		return
	
	if (Global.health <= 0):
		player_dead = true
		$AnimatedSprite2D.play("die")
		speed = 0
	elif (player_dead == false):
		get_input()
		apply_gravity()
		if not attacking:
			velocity.x = direction_x * speed
		else:
			velocity.x = 0
		move_and_slide()
		if dropping_through:
			if global_position.y > drop_platform_y + collision_reenable_offset:
				_enable_platform_collision()
		update_animation()
	else:
		pass
	if stun_timer > 0.0:
		stun_timer -= delta
		if stun_timer <= 0.0:
			speed = 150  
			attacking = false
			update_animation()


func get_input():
	direction_x = Input.get_axis("left", "right")
	
	if stun_timer > 0.0:
		return
	
	if is_on_floor():
		jumps_done = 0

	if Input.is_action_just_pressed("jump") and jumps_done < max_jumps and not attacking:
		velocity.y = -300
		jumps_done += 1
		$AnimatedSprite2D.stop()
		update_animation()

	elif Input.is_action_pressed("down") and is_on_floor() and not dropping_through and not attacking:
		dropping_through = true
		if $PlatformRay.is_colliding():
			drop_platform_y = $PlatformRay.get_collision_point().y
			set_collision_mask_value(4, false) 
		else:
			drop_platform_y = global_position.y
			$CollisionTimer.start()

	elif Input.is_action_just_pressed("attack") and is_on_floor() and not attacking and attack_cooldown_left <= 0.0:
		attack() 

func apply_gravity():
	velocity.y += 20

func update_animation():
	if stun_timer > 0.0:
		return
	
	if direction_x != 0:
		facing_left = direction_x < 0
	
	if attacking:
		return
		
	if not is_on_floor():
		$AnimatedSprite2D.play("jump")
	elif direction_x != 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("default")
	
	$AnimatedSprite2D.flip_h = facing_left

func _on_collision_reset_timer_timeout() -> void:
	set_collision_mask_value(4, true)

func _enable_platform_collision():
	set_collision_mask_value(4, true)
	dropping_through = false

func _on_animated_sprite_2d_animation_finished() -> void:
	attacking = false
	hitbox1.set_collision_mask_value(3, false)
	hitbox2.set_collision_mask_value(3, false)
	hitbox3.set_collision_mask_value(3, false)

func attack():
	if attack_cooldown_left <= 0.0:
		
		attacking = true
		attack_cooldown_left = attack_cooldown

		var flip = -1 if facing_left else 1

		hitbox1.scale.x = flip
		hitbox2.scale.x = flip
		hitbox3.scale.x = flip

		rng.randomize()
		var random_int = rng.randi_range(1, 3)

		if random_int == 1:
			hitbox1.set_collision_mask_value(3, true)
			$AnimatedSprite2D.play("attack1")
		elif random_int == 2:
			hitbox2.set_collision_mask_value(3, true)
			$AnimatedSprite2D.play("attack2")
		elif random_int == 3:
			hitbox3.set_collision_mask_value(3, true)
			$AnimatedSprite2D.play("attack3")

func take_damage (damage: int):
	if Global.health <= 0:
		return
	Global.health -= damage
	var root = get_tree().get_current_scene()
	var health_manager = root.get_node_or_null("UI")
	if health_manager:
		health_manager.update_health()
	$AnimatedSprite2D.play("hurt")
	speed = 0
	stun_timer = stun_time
	attacking = false
	direction_x = 0  
	
	if Global.health <= 0:
		var death_menu_scene = load("res://Scenes/death_menu.tscn")
		var death_menu_instance = death_menu_scene.instantiate()
		get_tree().get_current_scene().add_child(death_menu_instance)

func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		area.apply_damage(1)
