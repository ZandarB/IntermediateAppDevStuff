extends Node

@export var mob_scene: PackedScene
var score

func _on_player_hit() -> void:
	game_over()

func game_over():
	$StartTimer.stop()
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$DeathSound.play()


func new_game():
	score = 0
	$ScoreTimer.stop()
	$MobTimer.stop()
	$Player.start($StartPosition.position)
	$HUD.update_score(score)
	$HUD.show_message("Get ready!")
	get_tree().call_group("mobs", "queue_free")
	$StartTimer.start()


func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()

	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	mob.position = mob_spawn_location.position

	var direction = mob_spawn_location.rotation + PI / 2

	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	add_child(mob)

func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
