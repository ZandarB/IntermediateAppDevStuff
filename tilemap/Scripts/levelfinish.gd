extends Area2D

@export var melt: TextureRect       # assign the Melt TextureRect from CanvasLayer
@export var background: TextureRect # assign the Background TextureRect
@export var next_scene_path: String # optional

func _ready():
	melt.visible = false

# Capture the current screen and make it into the Melt TextureRect
func capture_screen():
	var img = get_viewport().get_texture().get_image()
	var tex = ImageTexture.create_from_image(img)
	melt.texture = tex
	print("Captured texture size:", melt.texture.get_size())

# Animate the shader uniformly
func start_melt(duration := 3.0) -> void:
	var shader_material = melt.material
	if shader_material == null:
		print("No shader assigned!")
		return
	shader_material.set_shader_parameter("progress", 0.0)
	var tween = create_tween()
	tween.tween_property(shader_material, "shader_parameter/progress", 1.0, duration)
	await tween.finished  

# Trigger when the player enters
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		background.visible = true # Show background and melt overlay
		melt.visible = true
		await get_tree().process_frame
		capture_screen()
		await start_melt(3.0) # Start melt and wait until it finishes

		# Only now change the scene
		if next_scene_path != "":
			get_tree().change_scene_to_file(next_scene_path)
