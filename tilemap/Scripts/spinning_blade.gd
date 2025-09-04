extends Area2D

var damage = 10
var ready_to_detect = false

func _ready():
	$AnimatedSprite2D.play("default")
	call_deferred("_enable_detection")

func _enable_detection():
	ready_to_detect = true

func _on_body_entered(body):
	print("Player touched the blade!")
