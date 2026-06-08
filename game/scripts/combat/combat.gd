extends Node2D

var xp_orb_scene: PackedScene = preload("res://scenes/combat/experience_orb.tscn")
var current_case: Dictionary = {}
var enemy_kill_count: int = 0

@onready var objective_tracker: Node = $objective_tracker

func _ready() -> void:
	current_case = CaseManager.get_current_case()
	objective_tracker.setup(current_case)
	objective_tracker.all_objectives_complete.connect(_on_all_objectives_done)
	EventBus.experience_dropped.connect(_on_experience_dropped)
	EventBus.enemy_killed.connect(_on_enemy_killed)
	EventBus.combat_started.emit()

func _on_experience_dropped(position: Vector2, amount: int) -> void:
	var orb: Area2D = xp_orb_scene.instantiate()
	orb.global_position = position
	orb.experience_amount = amount
	$experience_orbs.add_child(orb)

func _on_enemy_killed(_type: String, _pos: Vector2) -> void:
	enemy_kill_count += 1
	if enemy_kill_count % 5 == 0:
		objective_tracker.report_event("collect", "time_ticket", 1)
	if enemy_kill_count % 7 == 0:
		objective_tracker.report_event("disable", "broadcast_device", 1)

func _on_all_objectives_done() -> void:
	var boss_id: String = current_case.get("boss_id", "")
	if boss_id == "station_shadow":
		_spawn_station_boss()

func _spawn_station_boss() -> void:
	var boss_scene: PackedScene = preload("res://scenes/combat/boss/grey_line_conductor.tscn")
	if boss_scene:
		var boss: Node2D = boss_scene.instantiate()
		boss.global_position = Vector2(1920, 300)
		if boss.has_method("set_player_ref"):
			boss.set_player_ref($"entities/player")
		$entities/enemies.add_child(boss)
		EventBus.boss_spawned.emit()

func get_current_case() -> Dictionary:
	return current_case
