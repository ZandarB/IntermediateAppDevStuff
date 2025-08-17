extends CharacterBody2D

@export var speed = 150
@export var collision_reenable_offset = 4.0  # pixels below platform to re-enable collision
var direction_x = 0.0

var score: int = 0
var dropping_through = false
var drop_platform_y = 0.0
var max_jumps = 2
var jumps_done = 0


func _ready():
	$CollisionTimer.connect("timeout", Callable(self, "_on_collision_reset_timer_timeout"))
	$PlatformRay.enabled = true

func _process(_delta):
	get_input()
	apply_gravity()
	velocity.x = direction_x * speed

	move_and_slide()

	if dropping_through:
		if global_position.y > drop_platform_y + collision_reenable_offset:
			_enable_platform_collision()

	update_animation()

func get_input():
	direction_x = Input.get_axis("left", "right")

	if is_on_floor():
		jumps_done = 0

	if Input.is_action_just_pressed("jump") and jumps_done < max_jumps:
		velocity.y = -300
		jumps_done += 1
		$AnimatedSprite2D.stop()
		update_animation()
		
	elif Input.is_action_pressed("down") and is_on_floor() and not dropping_through:
		dropping_through = true
		set_collision_mask_value(4, false) 
		if $PlatformRay.is_colliding():
			drop_platform_y = $PlatformRay.get_collision_point().y
		else:
			drop_platform_y = global_position.y
		$CollisionTimer.start()

func apply_gravity():
	velocity.y += 20

func update_animation():
	if not is_on_floor():
		$AnimatedSprite2D.play("jump")

	elif direction_x != 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("default")

	$AnimatedSprite2D.flip_h = direction_x < 0

func _on_collision_reset_timer_timeout() -> void:
	set_collision_mask_value(4, true)

func _enable_platform_collision():
	set_collision_mask_value(4, true)
	dropping_through = false
