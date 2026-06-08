extends Area2D

var damage: int = 12
var orbit_speed: float = 3.0
var orbit_radius: float = 90.0
var orbit_angle: float = 0.0
var target_player: CharacterBody2D
var hit_cooldown: float = 0.3
var hit_timer: float = 0.0

func _ready() -> void:
	var visual: ColorRect = ColorRect.new()
	visual.color = Color(0.85, 0.75, 0.5, 0.9)
	visual.size = Vector2(20, 6)
	visual.position = Vector2(-10, -3)
	add_child(visual)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target_player):
		queue_free()
		return
	orbit_angle += orbit_speed * delta
	global_position = target_player.global_position + Vector2.RIGHT.rotated(orbit_angle) * orbit_radius
	rotation = orbit_angle + PI / 2
	hit_timer -= delta
	if hit_timer <= 0:
		_check_hit()

func _check_hit() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
	var bosses: Array[Node] = get_tree().get_nodes_in_group("boss")
	enemies.append_array(bosses)
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if global_position.distance_to(enemy.global_position) < 30:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)
				hit_timer = hit_cooldown
				break
