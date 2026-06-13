extends Node2D

var acquired_skills: Dictionary = {}
var skill_data: Dictionary = {}
var cooldown_timers: Dictionary = {}
var drone_container: Node2D
var sword_container: Node2D
var drone_scene: PackedScene = preload("res://scenes/combat/drone.tscn")
var sword_scene: PackedScene = preload("res://scenes/combat/coin_sword.tscn")
var effigy_scene: PackedScene = preload("res://scenes/combat/paper_effigy.tscn")
var whisper_mult: float = 1.0

@onready var weapon: Node2D = $"../weapon_system"
@onready var player: CharacterBody2D = $".."

func _ready() -> void:
	skill_data = DataLoader.load_json("res://data/skills/skills.json")
	drone_container = Node2D.new()
	drone_container.name = "drone_container"
	add_child(drone_container)
	sword_container = Node2D.new()
	sword_container.name = "sword_container"
	add_child(sword_container)

func acquire_skill(skill_id: String) -> void:
	if not skill_data.has(skill_id):
		return
	if not acquired_skills.has(skill_id):
		acquired_skills[skill_id] = 1
		cooldown_timers[skill_id] = 0.0
	else:
		var current_tier: int = acquired_skills[skill_id]
		var max_tier: int = skill_data[skill_id].max_tier
		if current_tier < max_tier:
			acquired_skills[skill_id] = current_tier + 1
		else:
			return
	_apply_skill_effect(skill_id)
	EventBus.skill_acquired.emit(skill_id, acquired_skills[skill_id])

func _apply_skill_effect(skill_id: String) -> void:
	var tier: int = acquired_skills[skill_id]
	var tier_data: Dictionary = skill_data[skill_id].tiers[tier - 1]
	match skill_id:
		"red_talisman_pulse":
			weapon.pierce_count = tier_data.pierce_bonus
			weapon.current_damage = int(weapon.base_damage * tier_data.damage_mult)
			if tier_data.has("multishot"):
				weapon.multishot = tier_data.multishot
		"whisper_circuit":
			whisper_mult = tier_data.damage_taken_mult
		"will_o_wisp_drone":
			_respawn_drones()
		"coin_sword_array":
			_respawn_swords()
		"paper_effigy_decoy":
			pass

func _respawn_drones() -> void:
	for child in drone_container.get_children():
		child.queue_free()
	var tier: int = acquired_skills.get("will_o_wisp_drone", 0)
	if tier == 0:
		return
	var data: Dictionary = skill_data.will_o_wisp_drone.tiers[tier - 1]
	for i in range(data.count):
		var drone: Node2D = drone_scene.instantiate()
		drone.damage = data.damage * whisper_mult
		drone.attack_interval = data.attack_interval
		drone.attack_range = data.range
		drone.orbit_angle = (TAU / data.count) * i
		drone.orbit_radius = 80.0
		drone.orbit_speed = 2.0
		drone.target_player = player
		drone_container.add_child(drone)

func _respawn_swords() -> void:
	for child in sword_container.get_children():
		child.queue_free()
	var tier: int = acquired_skills.get("coin_sword_array", 0)
	if tier == 0:
		return
	var data: Dictionary = skill_data.coin_sword_array.tiers[tier - 1]
	for i in range(data.count):
		var sword: Area2D = sword_scene.instantiate()
		sword.damage = data.damage * whisper_mult
		sword.orbit_speed = data.orbit_speed
		sword.orbit_radius = data.orbit_radius
		sword.orbit_angle = (TAU / data.count) * i
		sword.target_player = player
		sword_container.add_child(sword)

func _spawn_effigy(data: Dictionary) -> void:
	var effigy: Area2D = effigy_scene.instantiate()
	effigy.global_position = player.global_position
	effigy.lifetime = data.lifetime
	effigy.detonate_radius = data.detonate_radius
	effigy.detonate_damage = data.damage * whisper_mult
	get_tree().current_scene.add_child(effigy)

func _process(delta: float) -> void:
	for skill_id in acquired_skills:
		var tier: int = acquired_skills[skill_id]
		var type: String = skill_data[skill_id].type
		if type != "active_interval":
			if skill_id != "paper_effigy_decoy":
				continue
		if not cooldown_timers.has(skill_id):
			cooldown_timers[skill_id] = 0.0
		cooldown_timers[skill_id] -= delta
		if cooldown_timers[skill_id] <= 0:
			var tier_data: Dictionary = skill_data[skill_id].tiers[tier - 1]
			match skill_id:
				"azure_talisman_chain":
					_trigger_chain_lightning(tier_data)
				"thunder_seal_array":
					_trigger_thunder_ring(tier_data)
				"firewall_barrier":
					_trigger_shield(tier_data)
				"data_lightning":
					_trigger_data_lightning(tier_data)
				"black_iris_gaze":
					_trigger_black_iris(tier_data)
				"incense_ash_field":
					_trigger_incense_ash(tier_data)
				"old_camera_flash":
					_trigger_camera_flash(tier_data)
				"paper_effigy_decoy":
					_spawn_effigy(tier_data)
			cooldown_timers[skill_id] = tier_data.get("interval", tier_data.get("lifetime", 8.0))

func _trigger_chain_lightning(data: Dictionary) -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
	var bosses: Array[Node] = get_tree().get_nodes_in_group("boss")
	enemies.append_array(bosses)
	var sort_fn = func(a, b):
		return player.global_position.distance_to(a.global_position) < player.global_position.distance_to(b.global_position)
	enemies.sort_custom(sort_fn)
	var bounced: int = 0
	var current_pos: Vector2 = player.global_position
	var hit_set: Array[Node2D] = []
	for enemy in enemies:
		if enemy in hit_set:
			continue
		if current_pos.distance_to(enemy.global_position) > data.range:
			continue
		if bounced >= data.bounces:
			break
		if enemy.has_method("take_damage"):
			enemy.take_damage(data.damage * whisper_mult)
		hit_set.append(enemy)
		current_pos = enemy.global_position
		bounced += 1
	_draw_chain_vfx(player.global_position, hit_set)
	SoundManager.lightning()

func _draw_chain_vfx(origin: Vector2, targets: Array) -> void:
	var prev: Vector2 = origin
	for t in targets:
		var line: Line2D = Line2D.new()
		line.width = 3.0
		line.default_color = Color(0.3, 0.6, 1.0, 0.8)
		line.add_point(Vector2.ZERO)
		line.add_point(t.global_position - prev)
		line.global_position = prev
		get_tree().current_scene.add_child(line)
		var tw: Tween = create_tween()
		tw.tween_property(line, "modulate:a", 0.0, 0.3)
		tw.tween_callback(line.queue_free)
		prev = t.global_position

func _trigger_thunder_ring(data: Dictionary) -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
	var bosses: Array[Node] = get_tree().get_nodes_in_group("boss")
	enemies.append_array(bosses)
	for enemy in enemies:
		if player.global_position.distance_to(enemy.global_position) <= data.radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(data.damage * whisper_mult)
	SoundManager.lightning()
	var ring: ColorRect = ColorRect.new()
	ring.color = Color(1.0, 0.8, 0.2, 0.4)
	ring.size = Vector2(data.radius * 2, data.radius * 2)
	ring.position = Vector2(-data.radius, -data.radius)
	ring.global_position = player.global_position - Vector2(data.radius, data.radius)
	get_tree().current_scene.get_node("ui_layer").add_child(ring)
	var tw: Tween = create_tween()
	tw.tween_property(ring, "modulate:a", 0.0, 0.4)
		tw.tween_callback(ring.queue_free)
	SoundManager.lightning()

func _trigger_shield(data: Dictionary) -> void:
	player.invincible = true
	player.invincible_timer = data.duration
	var shield: ColorRect = ColorRect.new()
	shield.color = Color(1.0, 0.6, 0.1, 0.3)
	shield.size = Vector2(54, 54)
	shield.position = Vector2(-27, -27)
	shield.name = "shield_vfx"
	player.add_child(shield)
	var tw: Tween = create_tween()
	tw.tween_interval(data.duration)
	tw.tween_callback(func():
		player.invincible = false
		player.invincible_timer = 0.0
		shield.queue_free()
	)
	SoundManager.shield()

func _trigger_data_lightning(data: Dictionary) -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
	var bosses: Array[Node] = get_tree().get_nodes_in_group("boss")
	enemies.append_array(bosses)
	if enemies.is_empty():
		return
	for _i in range(data.targets):
		var target: Node2D = enemies[randi() % enemies.size()]
		if not is_instance_valid(target):
			continue
		if target.has_method("take_damage"):
			target.take_damage(data.damage * whisper_mult)
		var bolt: Line2D = Line2D.new()
		bolt.width = 2.0
		bolt.default_color = Color(0.2, 0.8, 1.0, 1.0)
		var mid: Vector2 = (player.global_position + target.global_position) / 2.0 + Vector2(randf_range(-40, 40), randf_range(-80, -20))
		bolt.add_point(Vector2.ZERO)
		bolt.add_point(mid - player.global_position)
		bolt.add_point(target.global_position - player.global_position)
		bolt.global_position = player.global_position
		get_tree().current_scene.add_child(bolt)
		var tw: Tween = create_tween()
		tw.tween_property(bolt, "modulate:a", 0.0, 0.25)
		tw.tween_callback(bolt.queue_free)
	SoundManager.lightning()

func _trigger_black_iris(data: Dictionary) -> void:
	var bosses: Array[Node] = get_tree().get_nodes_in_group("boss")
	if not bosses.is_empty():
		var boss: Node2D = bosses[0]
		if boss.has_method("take_damage"):
			boss.take_damage(data.damage * whisper_mult)
		player.current_hp = min(player.current_hp + int(player.max_hp * data.heal_pct), player.max_hp)
		EventBus.player_health_changed.emit(player.current_hp, player.max_hp)
	else:
		var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
		if not enemies.is_empty():
			var target: Node2D = enemies[randi() % enemies.size()]
			if target.has_method("take_damage"):
				target.take_damage(data.damage * whisper_mult * 0.6)
			player.current_hp = min(player.current_hp + int(player.max_hp * data.heal_pct * 0.5), player.max_hp)
			EventBus.player_health_changed.emit(player.current_hp, player.max_hp)

func _trigger_incense_ash(data: Dictionary) -> void:
	var radius: float = data.radius
	var ash: ColorRect = ColorRect.new()
	ash.color = Color(0.65, 0.63, 0.6, 0.35)
	ash.size = Vector2(radius * 2, radius * 2)
	ash.position = Vector2(-radius, -radius)
	ash.global_position = player.global_position - Vector2(radius, radius)
	get_tree().current_scene.add_child(ash)
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
	var bosses: Array[Node] = get_tree().get_nodes_in_group("boss")
	enemies.append_array(bosses)
	var slowed_enemies: Array = []
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if ash.global_position.distance_to(enemy.global_position) < radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(int(data.damage_per_sec * data.interval * whisper_mult) if data.has("interval") else int(data.damage_per_sec * whisper_mult))
			if enemy.get("move_speed") != null:
				var orig: float = enemy.move_speed
				enemy.move_speed *= (1.0 - data.slow)
				slowed_enemies.append({"enemy": enemy, "speed": orig})
	var tw: Tween = create_tween()
	tw.tween_property(ash, "modulate:a", 0.0, data.duration)
	tw.tween_callback(ash.queue_free)
	tw.tween_callback(func():
		for entry in slowed_enemies:
			if is_instance_valid(entry.enemy):
				entry.enemy.move_speed = entry.speed
	)
	SoundManager.ash()

func _trigger_camera_flash(data: Dictionary) -> void:
	var flash: ColorRect = ColorRect.new()
	flash.color = Color(1.0, 1.0, 1.0, 0.5)
	flash.size = Vector2(4000, 3000)
	flash.position = Vector2(-2000, -1500)
	get_tree().current_scene.add_child(flash)
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
	var bosses: Array[Node] = get_tree().get_nodes_in_group("boss")
	enemies.append_array(bosses)
	var slowed_enemies: Array = []
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if player.global_position.distance_to(enemy.global_position) < data.radius:
			if enemy.get("move_speed") != null:
				var orig: float = enemy.move_speed
				enemy.move_speed = max(orig * 0.15, 15.0)
				slowed_enemies.append({"enemy": enemy, "speed": orig})
	var tw: Tween = create_tween()
	tw.tween_property(flash, "modulate:a", 0.0, 0.3)
	tw.tween_callback(flash.queue_free)
	SoundManager.camera_flash()
	await get_tree().create_timer(data.blind_duration).timeout
	for entry in slowed_enemies:
		if is_instance_valid(entry.enemy):
			entry.enemy.move_speed = entry.speed
