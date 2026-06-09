extends Node

static var instance: Node = null

func _ready() -> void:
	instance = self

static func hit_particles(pos: Vector2, color: Color = Color.RED) -> void:
	if not instance:
		return
	for i in range(5):
		var p: ColorRect = ColorRect.new()
		p.color = color
		p.color.a = 0.8
		p.size = Vector2(4, 4)
		p.position = Vector2(-2, -2)
		p.global_position = pos
		var angle: float = randf_range(0, TAU)
		var dist: float = randf_range(20, 50)
		instance.get_tree().current_scene.add_child(p)
		var tw: Tween = instance.create_tween()
		tw.tween_property(p, "global_position", pos + Vector2.RIGHT.rotated(angle) * dist, 0.3)
		tw.parallel().tween_property(p, "modulate:a", 0.0, 0.3)
		tw.tween_callback(p.queue_free)

static func death_explosion(pos: Vector2, color: Color = Color.ORANGE) -> void:
	if not instance:
		return
	for i in range(12):
		var p: ColorRect = ColorRect.new()
		p.color = color
		p.color.a = 0.9
		p.size = Vector2(6, 6)
		p.position = Vector2(-3, -3)
		p.global_position = pos
		var angle: float = randf_range(0, TAU)
		var dist: float = randf_range(30, 80)
		instance.get_tree().current_scene.add_child(p)
		var tw: Tween = instance.create_tween()
		tw.tween_property(p, "global_position", pos + Vector2.RIGHT.rotated(angle) * dist, 0.5)
		tw.parallel().tween_property(p, "modulate:a", 0.0, 0.5)
		tw.parallel().tween_property(p, "size", Vector2(2, 2), 0.5)
		tw.tween_callback(p.queue_free)

static func screen_shake(intensity: float = 5.0, duration: float = 0.15) -> void:
	if not instance:
		return
	var tree: SceneTree = instance.get_tree()
	if not tree:
		return
	var root: Window = tree.root
	if not root:
		return
	var camera: Camera2D = tree.current_scene.get_node_or_null("camera")
	if not camera:
		return
	var orig_pos: Vector2 = camera.offset
	var elapsed: float = 0.0
	var tween: Tween = instance.create_tween()
	tween.tween_method(func(v):
		if not is_instance_valid(camera):
			return
		camera.offset = orig_pos + Vector2(randf_range(-v, v), randf_range(-v, v))
	, intensity, 0.0, duration)
	tween.tween_callback(func():
		if is_instance_valid(camera):
			camera.offset = orig_pos
	)

static func damage_number(pos: Vector2, amount: int, color: Color = Color.WHITE) -> void:
	if not instance:
		return
	var label: Label = Label.new()
	label.text = str(amount)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(60, 20)
	label.global_position = pos - Vector2(30, 0)
	instance.get_tree().current_scene.add_child(label)
	var tw: Tween = instance.create_tween()
	tw.set_parallel()
	tw.tween_property(label, "global_position", pos + Vector2(randf_range(-20, 20), -40), 0.7)
	tw.tween_property(label, "modulate:a", 0.0, 0.7)
	tw.tween_callback(label.queue_free)

static func boss_spawn_effect(pos: Vector2) -> void:
	if not instance:
		return
	for i in range(20):
		var p: ColorRect = ColorRect.new()
		p.color = Color(1.0, 0.2, 0.1, 0.8)
		p.size = Vector2(8, 8)
		p.position = Vector2(-4, -4)
		p.global_position = pos
		var angle: float = randf_range(0, TAU)
		var dist: float = randf_range(60, 150)
		instance.get_tree().current_scene.add_child(p)
		var tw: Tween = instance.create_tween()
		tw.tween_property(p, "global_position", pos + Vector2.RIGHT.rotated(angle) * dist, 0.7)
		tw.parallel().tween_property(p, "modulate:a", 0.0, 0.7)
		tw.parallel().tween_property(p, "size", Vector2(2, 2), 0.7)
		tw.tween_callback(p.queue_free)
	screen_shake(8.0, 0.3)
