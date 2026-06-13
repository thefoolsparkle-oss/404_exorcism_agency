extends "res://scripts/combat/boss/boss_base.gd"

var rush_cooldown: float = 4.0
var rush_timer: float = 1.5
var ripple_cooldown: float = 5.0
var ripple_timer: float = 3.0
var summon_cooldown: float = 8.0
var summon_timer: float = 4.0
var speed_boost: float = 1.0

func _init_boss() -> void:
	boss_name = "逆行列车长"

func _on_enrage() -> void:
	move_speed *= 1.6
	rush_cooldown *= 0.5
	ripple_cooldown *= 0.6
	summon_cooldown *= 0.7
	speed_boost = 1.3

func _update_boss_cooldowns(delta: float) -> void:
	rush_timer -= delta * speed_boost
	ripple_timer -= delta * speed_boost
	summon_timer -= delta * speed_boost
	if rush_timer <= 0:
		_temporal_rush()
		rush_timer = rush_cooldown
	if ripple_timer <= 0:
		_time_ripple()
		ripple_timer = ripple_cooldown
	if phase >= 2 and summon_timer <= 0:
		_spawn_enemy("time_echo", 2)
		summon_timer = summon_cooldown

func _temporal_rush() -> void:
	var dash_dir: Vector2 = (player.global_position - global_position).normalized()
	var target_pos: Vector2 = global_position + dash_dir * 350
	var indicator: Polygon2D = _make_path_indicator(global_position, target_pos, 50.0, Color(0, 0.8, 0.9, 0.3))
	get_tree().current_scene.add_child(indicator)
	is_casting = true
	var tw: Tween = create_tween()
	tw.tween_interval(0.4)
	tw.tween_callback(func():
		indicator.queue_free()
		var dash_tw: Tween = create_tween()
		dash_tw.tween_property(self, "global_position", target_pos, 0.15)
		dash_tw.tween_callback(func():
			is_casting = false
			if is_instance_valid(player) and player.global_position.distance_to(global_position) < 80:
				player.take_damage(contact_damage * 2)
				var orig: float = player.move_speed
				player.move_speed = max(orig * 0.3, 30.0)
				get_tree().create_timer(2.0).timeout.connect(func():
					if is_instance_valid(player):
						player.move_speed = orig
				)
		)
	)

func _time_ripple() -> void:
	is_casting = true
	var indicator: Polygon2D = _make_circle_indicator(global_position, 50.0, Color(0, 0.8, 0.9, 0.4))
	get_tree().current_scene.add_child(indicator)
	var tw: Tween = create_tween()
	tw.tween_property(indicator, "scale", Vector2(5, 5), 0.5)
	tw.parallel().tween_property(indicator, "modulate:a", 0.0, 0.5)
	tw.tween_callback(func():
		indicator.queue_free()
		is_casting = false
		if is_instance_valid(player) and player.global_position.distance_to(global_position) <= 250:
			player.take_damage(16)
	)
