extends "res://scripts/combat/boss/boss_base.gd"

var name_call_cooldown: float = 4.0
var name_call_timer: float = 2.0
var zone_cooldown: float = 6.0
var zone_timer: float = 3.0
var wave_cooldown: float = 5.0
var wave_timer: float = 2.5
var active_zones: Array = []

func _init_boss() -> void:
	boss_name = "广播寄生体"

func _on_enrage() -> void:
	move_speed *= 1.4
	name_call_cooldown *= 0.6
	zone_cooldown *= 0.6
	wave_cooldown *= 0.6

func _update_boss_cooldowns(delta: float) -> void:
	name_call_timer -= delta
	zone_timer -= delta
	if phase >= 2:
		wave_timer -= delta
	if name_call_timer <= 0:
		_name_call()
		name_call_timer = name_call_cooldown
	if zone_timer <= 0:
		_static_zone()
		zone_timer = zone_cooldown
	if phase >= 2 and wave_timer <= 0:
		_broadcast_wave()
		wave_timer = wave_cooldown
	_cleanup_zones()

func _name_call() -> void:
	is_casting = true
	var indicator: Polygon2D = _make_circle_indicator(global_position, 300.0, Color(0.5, 0.1, 0.5, 0.2))
	get_tree().current_scene.add_child(indicator)
	var tw: Tween = create_tween()
	tw.tween_interval(0.7)
	tw.tween_callback(func():
		indicator.queue_free()
		is_casting = false
		if not is_instance_valid(player):
			return
		if player.global_position.distance_to(global_position) <= 300:
			player.take_damage(18)
			_spawn_enemy("charmed_passenger", 1)
	)

func _static_zone() -> void:
	is_casting = true
	var targets: Array[Vector2] = [player.global_position]
	if phase >= 3:
		targets.append(player.global_position + Vector2(randf_range(-200, 200), randf_range(-200, 200)))
	for target in targets:
		var indicator: Polygon2D = _make_circle_indicator(target, 100.0, Color(0.5, 0, 0.5, 0.25))
		get_tree().current_scene.add_child(indicator)
		var zone_tw: Tween = create_tween()
		zone_tw.tween_interval(0.8)
		zone_tw.tween_callback(func():
			indicator.queue_free()
			var zone: ColorRect = ColorRect.new()
			zone.color = Color(0.5, 0, 0.6, 0.2)
			zone.size = Vector2(200, 200)
			zone.position = Vector2(-100, -100)
			zone.global_position = target
			get_tree().current_scene.add_child(zone)
			active_zones.append({"node": zone, "timer": 0.0})
		)
	var tw: Tween = create_tween()
	tw.tween_interval(1.0)
	tw.tween_callback(func(): is_casting = false)

func _broadcast_wave() -> void:
	is_casting = true
	var indicator: Polygon2D = _make_circle_indicator(global_position, 60.0, Color(0.5, 0.05, 0.6, 0.4))
	get_tree().current_scene.add_child(indicator)
	var tw: Tween = create_tween()
	tw.tween_property(indicator, "scale", Vector2(6, 6), 0.6)
	tw.parallel().tween_property(indicator, "modulate:a", 0.0, 0.6)
	tw.tween_callback(func():
		indicator.queue_free()
		is_casting = false
		if is_instance_valid(player) and player.global_position.distance_to(global_position) <= 360:
			player.take_damage(22)
	)

func _cleanup_zones() -> void:
	var to_remove: Array = []
	for entry in active_zones:
		if not is_instance_valid(entry.node):
			to_remove.append(entry)
			continue
		entry.timer += 0.016
		if entry.timer > 4.0:
			entry.node.queue_free()
			to_remove.append(entry)
		elif is_instance_valid(player) and entry.node.global_position.distance_to(player.global_position) < 100:
			player.take_damage(5)
	for entry in to_remove:
		active_zones.erase(entry)

func _physics_process(delta: float) -> void:
	super(delta)
	_cleanup_zones()

func _die() -> void:
	for entry in active_zones:
		if is_instance_valid(entry.node):
			entry.node.queue_free()
	active_zones.clear()
	super._die()
