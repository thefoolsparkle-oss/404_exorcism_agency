extends Area2D

var lifetime: float = 8.0
var detonate_radius: float = 120.0
var detonate_damage: int = 20
var attract_range: float = 300.0
var age: float = 0.0

var pulse_timer: float = 0.0

func _ready() -> void:
	add_to_group("paper_decoy")
	var visual: ColorRect = ColorRect.new()
	visual.color = Color(1.0, 0.95, 0.85, 0.8)
	visual.size = Vector2(24, 24)
	visual.position = Vector2(-12, -12)
	add_child(visual)

func _physics_process(delta: float) -> void:
	age += delta
	pulse_timer += delta
	if pulse_timer > 0.8 + age * 0.5:
		pulse_timer = 0.0
		_attract_enemies()
	if age >= lifetime:
		_detonate()

func _attract_enemies() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
	var bosses: Array[Node] = get_tree().get_nodes_in_group("boss")
	enemies.append_array(bosses)
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if global_position.distance_to(enemy.global_position) < attract_range:
			if enemy.has_method("_force_target"):
				enemy.global_position = enemy.global_position.move_toward(global_position, 80.0)

func _on_hit() -> void:
	_detonate()

func _detonate() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
	var bosses: Array[Node] = get_tree().get_nodes_in_group("boss")
	enemies.append_array(bosses)
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if global_position.distance_to(enemy.global_position) <= detonate_radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(detonate_damage)
	var ring: ColorRect = ColorRect.new()
	ring.color = Color(1.0, 0.85, 0.5, 0.5)
	ring.size = Vector2(detonate_radius * 2, detonate_radius * 2)
	ring.position = Vector2(-detonate_radius, -detonate_radius)
	ring.global_position = global_position - Vector2(detonate_radius, detonate_radius)
	get_tree().current_scene.add_child(ring)
	var tw: Tween = create_tween()
	tw.tween_property(ring, "modulate:a", 0.0, 0.4)
	tw.tween_callback(ring.queue_free)
	queue_free()
