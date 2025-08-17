extends Node

func _on_key_body_entered(body: Node2D) -> void:
	_handle_key(Vector2i(48, 25), "Key")

func _on_key_2_body_entered(body: Node2D) -> void:
	_handle_key(Vector2i(75, 42), "Key2")

func _handle_key(start_pos: Vector2i, key_name: String) -> void:
	var tilemap = get_node("../TileMaps/TileMapLayer")
	if tilemap:
		tilemap.set_cell(start_pos, 4, Vector2i(13, 94))
		tilemap.set_cell(start_pos + Vector2i(0, 1), 4, Vector2i(13, 95))

	var key_path = "/root/Level2/Pickups/" + key_name
	var key_node = get_node_or_null(key_path)
	if key_node:
		key_node.queue_free()
