extends "res://scripts/combat/boss/boss_base.gd"

var shadow_cooldown: float = 5.0
var shadow_timer: float = 2.0
var pulse_cooldown: float = 4.0
var pulse_timer: float = 1.5

func _init_boss() -> void:
	boss_name = "站台暗影"

func _on_enrage() -> void:
	move_speed *= 1.5
	shadow_cooldown *= 0.6
	pulse_cooldown *= 0.7

func _update_boss_cooldowns(delta: float) -> void:
	shadow_timer -= delta
	pulse_timer -= delta
	if shadow_timer <= 0:
		_shadow_ambush()
		shadow_timer = shadow_cooldown
	if pulse_timer <= 0:
		_dark_pulse()
		pulse_timer = pulse_cooldown

func _shadow_ambush() -> void:
	is_casting = true
	var indicator: Polygon2D = _make_circle_indicator(global_position, 120.0, Color(0.05, 0.02, 0.1, 0.4))
	get_tree().current_scene.add_child(indicator)
	var tw: Tween = create_tween()
	tw.tween_interval(0.5)
	tw.tween_callback(func():
		indicator.queue_free()
		_shoot_shadow_spread()
		_spawn_enemy("shadow_fragment", 2)
		var angle: float = randf_range(0, TAU)
		var dist: float = randf_range(200, 400)
		global_position = player.global_position + Vector2.RIGHT.rotated(angle) * dist
		is_casting = false
	)

func _shoot_shadow_spread() -> void:
	var proj_scene: PackedScene = preload("res://scenes/combat/enemy_projectile.tscn")
	for i in range(6):
		var proj: Area2D = proj_scene.instantiate()
		proj.global_position = global_position
		proj.direction = Vector2.RIGHT.rotated(TAU * i / 6.0)
		proj.speed = 150.0
		proj.damage = 8
		get_tree().current_scene.get_node_or_null("projectiles")?.add_child(proj)

func _dark_pulse() -> void:
	is_casting = true
	var indicator: Polygon2D = _make_circle_indicator(global_position, 200.0, Color(0.08, 0.03, 0.15, 0.3))
	get_tree().current_scene.add_child(indicator)
	var tw: Tween = create_tween()
	tw.tween_interval(0.7)
	tw.tween_callback(func():
		indicator.queue_free()
		if not is_instance_valid(player):
			return
		if player.global_position.distance_to(global_position) <= 200:
			player.take_damage(15)
			player.move_speed *= 0.6
			var orig: float = player.move_speed / 0.6
			get_tree().create_timer(1.5).timeout.connect(func():
				if is_instance_valid(player):
					player.move_speed = orig
			)
		is_casting = false
	)
