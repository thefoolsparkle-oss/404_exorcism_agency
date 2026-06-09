extends Node2D

@export var spawn_interval_min: float = 3.0
@export var spawn_interval_max: float = 1.0
@export var ramp_duration: float = 120.0
@export var boss_spawn_time: float = 120.0
@export var spawn_area_size: float = 500.0
@export var min_spawn_distance: float = 400.0

var timer: float = 0.0
var next_spawn: float = 3.0
var game_timer: float = 0.0
var boss_spawned: bool = false
var enabled: bool = false
var enemy_data: Dictionary = {}
var enemy_scene: PackedScene = preload("res://scenes/combat/enemies/enemy_base.tscn")
var current_case: Dictionary = {}
var boss_triggered_by_objectives: bool = false

@onready var player: CharacterBody2D = $"../entities/player"
@onready var enemies_container: Node2D = $"../entities/enemies"

func _ready() -> void:
	enemy_data = DataLoader.load_json("res://data/enemies/enemies.json")
	current_case = CaseManager.get_current_case()
	if not current_case.is_empty():
		spawn_interval_min = current_case.get("spawn_interval_min", spawn_interval_min)
		spawn_interval_max = current_case.get("spawn_interval_max", spawn_interval_max)
		ramp_duration = current_case.get("ramp_duration", ramp_duration)
		boss_spawn_time = current_case.get("boss_spawn_time", boss_spawn_time)

	var objectives: Array = current_case.get("objectives", [])
	for obj in objectives:
		if obj.get("type") == "defeat_boss":
			boss_triggered_by_objectives = true

	EventBus.combat_started.connect(_on_combat_started)
	EventBus.combat_ended.connect(_on_combat_ended)
	EventBus.combat_paused.connect(_on_paused)
	EventBus.combat_resumed.connect(_on_resumed)

	var tracker = get_tree().current_scene.get_node_or_null("objective_tracker")
	if tracker:
		tracker.all_objectives_complete.connect(_on_objectives_done)

func _on_combat_started() -> void:
	enabled = true
	game_timer = 0.0
	timer = 0.0
	next_spawn = spawn_interval_min
	boss_spawned = false

func _on_combat_ended(_victory: bool) -> void:
	enabled = false

func _on_paused() -> void:
	enabled = false

func _on_resumed() -> void:
	enabled = true

func _process(delta: float) -> void:
	if not enabled:
		return

	game_timer += delta

	if game_timer >= boss_spawn_time and not boss_spawned:
		_spawn_boss()
		return

	timer += delta
	if timer >= next_spawn:
		timer = 0.0
		_spawn_enemy()
		var t: float = min(game_timer / ramp_duration, 1.0)
		next_spawn = lerp(spawn_interval_min, spawn_interval_max, t)

func _on_objectives_done() -> void:
	_spawn_boss()

func _spawn_enemy() -> void:
	var spawn_pos: Vector2 = _get_spawn_position()
	var enemy_type: String = _choose_enemy_type()
	if not enemy_data.has(enemy_type):
		return

	var enemy: CharacterBody2D = enemy_scene.instantiate()
	enemy.global_position = spawn_pos

	var data: Dictionary = enemy_data[enemy_type]
	enemy.enemy_id = enemy_type
	enemy.max_hp = data.get("hp", 30)
	enemy.move_speed = data.get("move_speed", 100.0)
	enemy.damage = data.get("damage", 10)
	enemy.contact_damage = data.get("contact_damage", true)
	enemy.attack_range = data.get("attack_range", 0.0)
	enemy.attack_cooldown = data.get("attack_cooldown", 0.0)
	enemy.projectile_speed = data.get("projectile_speed", 200.0)
	enemy.experience_drop = data.get("experience_drop", 10)
	enemy.enemy_size = data.get("size", 30.0)
	enemy.enemy_color = Color(data.get("color", "gray"))
	enemy.has_special = data.get("special", "")
	enemy.teleport_cooldown = data.get("teleport_cooldown", 3.0)
	enemy.set_player_ref(player)

	enemies_container.add_child(enemy)
	EventBus.enemy_spawned.emit(enemy)

func _get_spawn_position() -> Vector2:
	var angle: float = randf_range(0, TAU)
	var dist: float = randf_range(min_spawn_distance, min_spawn_distance + 300.0)
	var pos: Vector2 = player.global_position + Vector2.RIGHT.rotated(angle) * dist
	pos.x = clamp(pos.x, 50, 3790)
	pos.y = clamp(pos.y, 50, 2110)
	return pos

func _choose_enemy_type() -> String:
	var pool: Array = current_case.get("enemy_pool", ["empty_seat_passenger", "reverse_walker", "low_frequency_shade"])
	if game_timer < 30:
		return pool[0] if pool.size() > 0 else "empty_seat_passenger"
	elif game_timer < 60:
		return pool[randi() % min(2, pool.size())]
	else:
		return pool[randi() % pool.size()]

func _spawn_boss() -> void:
	boss_spawned = true
	var boss_id: String = current_case.get("boss_id", "grey_line_conductor")
	var boss_path: String = "res://scenes/combat/boss/" + boss_id + ".tscn"
	var boss_scene: PackedScene
	if ResourceLoader.exists(boss_path):
		boss_scene = load(boss_path)
	else:
		boss_scene = preload("res://scenes/combat/boss/grey_line_conductor.tscn")
	if boss_scene:
		var boss: Node2D = boss_scene.instantiate()
		var angle: float = randf_range(0, TAU)
		boss.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * 400
		boss.global_position.x = clamp(boss.global_position.x, 100, 3740)
		boss.global_position.y = clamp(boss.global_position.y, 100, 2060)
		if boss.has_method("set_player_ref"):
			boss.set_player_ref(player)
		var boss_stats: Dictionary = current_case.get("boss_stats", {})
		if boss_stats.has("max_hp"):
			boss.max_hp = boss_stats.max_hp
			boss.current_hp = boss_stats.max_hp
		if boss_stats.has("move_speed"):
			boss.move_speed = boss_stats.move_speed
		if boss_stats.has("contact_damage"):
			boss.contact_damage = boss_stats.contact_damage
		enemies_container.add_child(boss)
		VFXManager.boss_spawn_effect(boss.global_position)
		EventBus.boss_spawned.emit()
