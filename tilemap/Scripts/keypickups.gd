extends Node

func _on_key_body_entered(body: Node2D) -> void:
	_handle_key(Vector2i(48, 25), "Key", "Level2")

func _on_key_2_body_entered(body: Node2D) -> void:
	_handle_key(Vector2i(75, 42), "Key2", "Level2")
	
func _on_key_3_body_entered(body: Node2D) -> void:
	_handle_key(Vector2i(71, -6), "Key3", "Level3")
	
func _handle_key(start_pos: Vector2i, key_name: String, level_name: String) -> void:
	var tilemap = get_node("../TileMaps/TileMapLayer")
	if tilemap:
		tilemap.set_cell(start_pos, 4, Vector2i(13, 94))
		tilemap.set_cell(start_pos + Vector2i(0, 1), 4, Vector2i(13, 95))

	var key_path = "/root/" + level_name + "/Pickups/" + key_name
	var key_node = get_node_or_null(key_path)
	key_node.queue_free()
