extends Node2D

var acquired_skills: Dictionary = {}
var skill_data: Dictionary = {}
var cooldown_timers: Dictionary = {}
var drone_scene: PackedScene = preload("res://scenes/combat/drone.tscn")
var drone_container: Node2D

@onready var weapon: Node2D = $"../weapon_system"
@onready var player: CharacterBody2D = $".."

func _ready() -> void:
	skill_data = DataLoader.load_json("res://data/skills/skills.json")
	drone_container = Node2D.new()
	drone_container.name = "drone_container"
	add_child(drone_container)

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
		"will_o_wisp_drone":
			_respawn_drones(tier_data)

func _respawn_drones(data: Dictionary) -> void:
	for child in drone_container.get_children():
		child.queue_free()
	for i in range(data.count):
		var drone: Node2D = drone_scene.instantiate()
		drone.damage = data.damage
		drone.attack_interval = data.attack_interval
		drone.attack_range = data.range
		drone.orbit_angle = (TAU / data.count) * i
		drone.orbit_radius = 80.0
		drone.orbit_speed = 2.0
		drone.target_player = player
		drone_container.add_child(drone)

func _process(delta: float) -> void:
	for skill_id in acquired_skills:
		var tier: int = acquired_skills[skill_id]
		var type: String = skill_data[skill_id].type
		if type != "active_interval":
			continue
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
			cooldown_timers[skill_id] = tier_data.interval

func _trigger_chain_lightning(data: Dictionary) -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
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
			enemy.take_damage(data.damage)
		hit_set.append(enemy)
		current_pos = enemy.global_position
		bounced += 1
	_draw_chain_vfx(player.global_position, hit_set)

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
	for enemy in enemies:
		if player.global_position.distance_to(enemy.global_position) <= data.radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(data.damage)
	var ring: ColorRect = ColorRect.new()
	ring.color = Color(1.0, 0.8, 0.2, 0.4)
	ring.size = Vector2(data.radius * 2, data.radius * 2)
	ring.position = Vector2(-data.radius, -data.radius)
	ring.global_position = player.global_position - Vector2(data.radius, data.radius)
	get_tree().current_scene.get_node("ui_layer").add_child(ring)
	var tw: Tween = create_tween()
	tw.tween_property(ring, "modulate:a", 0.0, 0.4)
	tw.tween_callback(ring.queue_free)

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
