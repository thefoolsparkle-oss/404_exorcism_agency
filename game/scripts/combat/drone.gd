extends Area2D

var damage: int = 8
var attack_interval: float = 1.0
var attack_range: float = 250.0
var orbit_angle: float = 0.0
var orbit_radius: float = 80.0
var orbit_speed: float = 2.0
var target_player: CharacterBody2D

var attack_timer: float = 0.0
var projectile_scene: PackedScene = preload("res://scenes/combat/player_projectile.tscn")

func _ready() -> void:
	attack_timer = attack_interval * randf()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target_player):
		queue_free()
		return

	orbit_angle += orbit_speed * delta
	global_position = target_player.global_position + Vector2.RIGHT.rotated(orbit_angle) * orbit_radius

	attack_timer -= delta
	if attack_timer <= 0:
		var target: Node2D = _find_nearest_enemy()
		if target:
			var proj: Area2D = projectile_scene.instantiate()
			proj.global_position = global_position
			proj.direction = (target.global_position - global_position).normalized()
			proj.speed = 300.0
			proj.damage = damage
			proj.pierce_remaining = 0
			get_tree().current_scene.get_node("projectiles").add_child(proj)
		attack_timer = attack_interval

func _find_nearest_enemy() -> Node2D:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
	var bosses: Array[Node] = get_tree().get_nodes_in_group("boss")
	enemies.append_array(bosses)
	var nearest: Node2D = null
	var nearest_dist: float = attack_range
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist: float = global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest
