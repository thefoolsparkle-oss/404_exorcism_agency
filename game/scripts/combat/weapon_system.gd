extends Node2D

@export var base_attack_interval: float = 0.5
@export var base_damage: int = 10
@export var projectile_speed: float = 400.0
@export var attack_range: float = 500.0

var current_damage: int
var current_attack_interval: float
var attack_timer: float = 0.0
var multishot: int = 1
var pierce_count: int = 0

var projectile_scene: PackedScene = preload("res://scenes/combat/player_projectile.tscn")

func _ready() -> void:
	current_damage = base_damage
	current_attack_interval = base_attack_interval

func _process(delta: float) -> void:
	attack_timer -= delta
	if attack_timer <= 0:
		var target: Node2D = _find_nearest_enemy()
		if target:
			_shoot(target)
			attack_timer = current_attack_interval

func _find_nearest_enemy() -> Node2D:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
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

func _shoot(target: Node2D) -> void:
	var base_dir: Vector2 = (target.global_position - global_position).normalized()
	var spread_angle: float = deg_to_rad(10.0)

	for i in range(multishot):
		var angle_offset: float = (i - (multishot - 1) / 2.0) * spread_angle
		var dir: Vector2 = base_dir.rotated(angle_offset)
		var proj: Area2D = projectile_scene.instantiate()
		proj.global_position = global_position
		proj.direction = dir
		proj.speed = projectile_speed
		proj.damage = current_damage
		proj.pierce_remaining = pierce_count
		get_tree().current_scene.get_node("projectiles").add_child(proj)
