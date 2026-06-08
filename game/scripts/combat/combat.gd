extends Node2D

var xp_orb_scene: PackedScene = preload("res://scenes/combat/experience_orb.tscn")
var current_case: Dictionary = {}
var narrative_scene: PackedScene = preload("res://scenes/ui/narrative_screen.tscn")

@onready var objective_tracker: Node = $objective_tracker

func _ready() -> void:
	current_case = CaseManager.get_current_case()
	objective_tracker.setup(current_case)
	objective_tracker.all_objectives_complete.connect(_on_all_objectives_done)
	EventBus.experience_dropped.connect(_on_experience_dropped)
	EventBus.enemy_killed.connect(_on_enemy_killed)
	EventBus.combat_ended.connect(_on_combat_ended)
	_apply_relics()
	_grant_starter_skill()
	_apply_character_passive()
	EventBus.combat_started.emit()

func _on_enemy_killed(_type: String, _pos: Vector2) -> void:
	var player = $entities/player
	if player and player.has_lifesteal:
		player.current_hp = min(player.current_hp + int(player.max_hp * player.lifesteal_pct), player.max_hp)
		EventBus.player_health_changed.emit(player.current_hp, player.max_hp)

func _on_combat_ended(victory: bool) -> void:
	if not victory:
		return
	var case_id: String = current_case.get("case_id", "")
	var threat: int = current_case.get("threat_level", 1)
	var player = $entities/player
	var lv: int = player.level if player else 1
	var essence: int = threat * 50 + lv * 10
	SaveManager.add_resource("anomaly_essence", essence)
	SaveManager.add_resource("broken_circuit", threat)
	SaveManager.complete_case(case_id)
	SaveManager.save()
	
	var narrative_data: Dictionary = DataLoader.load_json("res://data/narrative/grey_line.json")
	var case_stories: Dictionary = narrative_data.get("case_complete", {})
	var story: Dictionary = case_stories.get(case_id, {})
	if story.is_empty():
		return
	var narrative: CanvasLayer = narrative_scene.instantiate()
	narrative.finished.connect(func():
		EventBus.request_main_menu.emit()
	)
	get_tree().current_scene.add_child(narrative)
	narrative.show_narrative(story.get("title", ""), "", story.get("lines", []))

func _grant_starter_skill() -> void:
	var char_data: Dictionary = DataLoader.load_json("res://data/characters/characters.json")
	var selected: String = SaveManager.data.selected_character
	var stats: Dictionary = char_data.get(selected, {})
	var starter: String = stats.get("starter_skill", "")
	if starter:
		var player = $entities/player
		player.get_node("skill_system").acquire_skill(starter)

func _apply_character_passive() -> void:
	var player = $entities/player
	var selected: String = SaveManager.data.selected_character
	match selected:
		"bai_zhi":
			player.has_lifesteal = true
			player.lifesteal_pct = 0.12

var esc_was_pressed: bool = false
var pause_was_pressed: bool = false

func _process(_delta: float) -> void:
	var esc_now: bool = Input.is_key_pressed(KEY_ESCAPE)
	var p_now: bool = Input.is_key_pressed(KEY_P)
	if (esc_now and not esc_was_pressed) or (p_now and not pause_was_pressed):
		if GameManager.current_state == GameManager.GameState.COMBAT_ACTIVE:
			_show_pause_menu()
	esc_was_pressed = esc_now
	pause_was_pressed = p_now

func _show_pause_menu() -> void:
	if GameManager.current_state != GameManager.GameState.COMBAT_ACTIVE:
		return
	get_tree().paused = false
	var popup: AcceptDialog = AcceptDialog.new()
	popup.title = "暂停"
	popup.dialog_text = "是否返回事务所？"
	popup.confirmed.connect(func():
		SaveManager.save()
		get_tree().change_scene_to_file("res://scenes/office/office_main.tscn")
	)
	popup.canceled.connect(func():
		pass
	)
	get_tree().current_scene.add_child(popup)
	popup.popup_centered()

func _on_experience_dropped(position: Vector2, amount: int) -> void:
	var orb: Area2D = xp_orb_scene.instantiate()
	orb.global_position = position
	orb.experience_amount = amount
	$experience_orbs.add_child(orb)

func _on_all_objectives_done() -> void:
	$spawn_director._spawn_boss()

func _apply_relics() -> void:
	var relics_data: Dictionary = DataLoader.load_json("res://data/skills/relics.json")
	var case_data: Dictionary = DataLoader.load_json("res://data/cases/approved_cases.json")
	var player = $entities/player
	if not player:
		return
	for case_id in SaveManager.data.completed_cases:
		var case_info: Dictionary = case_data.get(case_id, {})
		for reward_id in case_info.get("reward_items", []):
			var relic: Dictionary = relics_data.get(reward_id, {})
			var effect: Dictionary = relic.get("effect", {})
			if effect.has("max_hp_bonus"):
				player.max_hp += effect.max_hp_bonus
				player.current_hp += effect.max_hp_bonus
			if effect.has("speed_mult"):
				player.move_speed *= effect.speed_mult
			if effect.has("pierce_bonus"):
				player.get_node("weapon_system").pierce_count += effect.pierce_bonus
			if effect.has("damage_mult"):
				var w = player.get_node("weapon_system")
				w.base_damage = int(w.base_damage * effect.damage_mult)
				w.current_damage = w.base_damage
			if effect.has("xp_mult"):
				player.experience_to_next = int(player.experience_to_next / effect.xp_mult)
	EventBus.player_health_changed.emit(player.current_hp, player.max_hp)

func get_current_case() -> Dictionary:
	return current_case
