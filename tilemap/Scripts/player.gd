extends CharacterBody2D

@export var speed = 150
@export var collision_reenable_offset = 4.0  # pixels below platform to re-enable collision
@onready var hitbox1 = $Attack1Hitbox
@onready var hitbox2 = $Attack2Hitbox
@onready var hitbox3 = $Attack3Hitbox

var score: int = 0
var dropping_through = false
var drop_platform_y = 0.0
var max_jumps = 2
var jumps_done = 0
var rng = RandomNumberGenerator.new()
var facing_left = false
var attacking = false
var direction_x = 0.0

func _ready():
	$CollisionTimer.connect("timeout", Callable(self, "_on_collision_reset_timer_timeout"))
	$PlatformRay.enabled = true

func _physics_process(delta):
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

func get_input():
	direction_x = Input.get_axis("left", "right")

	if is_on_floor():
		jumps_done = 0

	if Input.is_action_just_pressed("jump") and jumps_done < max_jumps and not attacking:
		velocity.y = -300
		jumps_done += 1
		$AnimatedSprite2D.stop()
		update_animation()

	elif Input.is_action_pressed("down") and is_on_floor() and not dropping_through and not attacking:
		dropping_through = true
		set_collision_mask_value(4, false) 
		if $PlatformRay.is_colliding():
			drop_platform_y = $PlatformRay.get_collision_point().y
		else:
			drop_platform_y = global_position.y
			$CollisionTimer.start()

	elif Input.is_action_pressed("attack") and is_on_floor() and not dropping_through and not attacking:
		attack() 

func apply_gravity():
	velocity.y += 20

func update_animation():
	if direction_x != 0:
		facing_left = direction_x < 0
	
	if attacking == true:
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
	hitbox1.set_collision_layer_value(3, false)
	hitbox2.set_collision_layer_value(3, false)
	hitbox3.set_collision_layer_value(3, false)

func attack():
	attacking = true

	var flip = -1 if facing_left else 1

	hitbox1.scale.x = flip
	hitbox2.scale.x = flip
	hitbox3.scale.x = flip

	rng.randomize()
	var random_int = rng.randi_range(1, 3)

	if random_int == 1:
		hitbox1.set_collision_layer_value(3, true)
		$AnimatedSprite2D.play("attack1")
	elif random_int == 2:
		hitbox2.set_collision_layer_value(3, true)
		$AnimatedSprite2D.play("attack2")
	elif random_int == 3:
		hitbox3.set_collision_layer_value(3, true)
		$AnimatedSprite2D.play("attack3")

func take_damage (damage: int):
	print("amogus")
