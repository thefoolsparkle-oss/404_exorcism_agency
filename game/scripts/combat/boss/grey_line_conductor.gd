extends CharacterBody2D

@export var max_hp: int = 500
@export var move_speed: float = 100.0
@export var contact_damage: int = 30

var current_hp: int
var phase: int = 1
var enraged: bool = false
var is_dashing: bool = false

var ticket_punch_cooldown: float = 3.0
var ticket_punch_timer: float = 1.0
var summon_cooldown: float = 8.0
var summon_timer: float = 4.0
var broadcast_cooldown: float = 6.0
var broadcast_timer: float = 3.0

var player: CharacterBody2D
var enemy_scene: PackedScene = preload("res://scenes/combat/enemies/enemy_base.tscn")
var enemy_data: Dictionary = {}

@onready var visual: ColorRect = $visual
@onready var hp_bar: ProgressBar = $boss_hp_bar
@onready var boss_label: Label = $boss_label

func _ready() -> void:
	current_hp = max_hp
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	boss_label.text = "BOSS"
	enemy_data = DataLoader.load_json("res://data/enemies/enemies.json")

func set_player_ref(p: CharacterBody2D) -> void:
	player = p

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	_update_phase()
	_update_cooldowns(delta)
	if not is_dashing:
		_chase_player()
		move_and_slide()
	else:
		velocity = Vector2.ZERO
	queue_redraw()

func _draw() -> void:
	var tex: Texture2D = AssetLoader.get_boss_sprite("grey_line_conductor")
	if tex:
		draw_texture_rect(tex, Rect2(Vector2(-78, -110), Vector2(156, 156)), false)
	else:
		SpriteDrawer.draw_boss(self, Vector2.ZERO, "grey_line_conductor", 120.0, Time.get_ticks_msec() * 0.001)

func _update_phase() -> void:
	var hp_percent: float = float(current_hp) / float(max_hp)
	if hp_percent <= 0.3 and phase < 3:
		phase = 3
		if not enraged:
			enraged = true
			move_speed *= 1.5
			ticket_punch_cooldown *= 0.7
			boss_label.text = "BOSS (暴怒)"
	elif hp_percent <= 0.6 and phase < 2:
		phase = 2

func _update_cooldowns(delta: float) -> void:
	ticket_punch_timer -= delta
	summon_timer -= delta
	broadcast_timer -= delta
	if ticket_punch_timer <= 0:
		_ticket_punch()
		ticket_punch_timer = ticket_punch_cooldown
	if summon_timer <= 0:
		_summon_passengers()
		summon_timer = summon_cooldown
	if phase >= 2 and broadcast_timer <= 0:
		_broadcast_static()
		broadcast_timer = broadcast_cooldown

func _chase_player() -> void:
	var dir: Vector2 = (player.global_position - global_position).normalized()
	velocity = dir * move_speed

func _ticket_punch() -> void:
	var dash_dir: Vector2 = (player.global_position - global_position).normalized()
	var target_pos: Vector2 = global_position + dash_dir * 300
	var indicator: Polygon2D = _make_path_indicator(global_position, target_pos, 64.0, Color(1, 0.08, 0.04, 0.28))
	var impact_indicator: Polygon2D = _make_circle_indicator(target_pos, 90.0, Color(1, 0.6, 0.05, 0.18))
	get_tree().current_scene.add_child(indicator)
	get_tree().current_scene.add_child(impact_indicator)
	is_dashing = true
	var tw: Tween = create_tween()
	tw.tween_interval(0.6)
	tw.tween_callback(func():
		indicator.queue_free()
		impact_indicator.queue_free()
		var dash_tw: Tween = create_tween()
		var start_pos: Vector2 = global_position
		dash_tw.tween_property(self, "global_position", target_pos, 0.25)
		dash_tw.tween_callback(func():
			is_dashing = false
			if _distance_to_segment(player.global_position, start_pos, target_pos) < 45.0 or player.global_position.distance_to(target_pos) < 90.0:
				player.take_damage(contact_damage * 2)
		)
	)

func _summon_passengers() -> void:
	var enemy: CharacterBody2D = enemy_scene.instantiate()
	enemy.enemy_id = "empty_seat_passenger"
	var data: Dictionary = enemy_data.get("empty_seat_passenger", {})
	enemy.max_hp = data.get("hp", 20)
	enemy.move_speed = data.get("move_speed", 120.0)
	enemy.damage = data.get("damage", 10)
	enemy.contact_damage = true
	enemy.enemy_size = data.get("size", 30.0)
	enemy.enemy_color = Color(data.get("color", "gray"))
	enemy.set_player_ref(player)
	enemy.global_position = global_position + Vector2(randf_range(-150, 150), randf_range(-150, 150))
	get_tree().current_scene.get_node("entities/enemies").add_child(enemy)

func _broadcast_static() -> void:
	var radius: float = 250.0
	var indicator: Polygon2D = _make_circle_indicator(global_position, radius, Color(0.55, 0, 0.75, 0.24))
	get_tree().current_scene.add_child(indicator)
	is_dashing = true
	var tw: Tween = create_tween()
	tw.tween_interval(0.8)
	tw.tween_callback(func():
		indicator.queue_free()
		is_dashing = false
		if not is_instance_valid(player):
			return
		if player.global_position.distance_to(global_position) <= radius:
			player.take_damage(20)
			var original_speed: float = player.move_speed
			player.move_speed *= 0.5
			get_tree().create_timer(2.0).timeout.connect(func():
				if is_instance_valid(player):
					player.move_speed = original_speed
			)
	)

func _make_path_indicator(start_pos: Vector2, end_pos: Vector2, width: float, color: Color) -> Polygon2D:
	var dir: Vector2 = (end_pos - start_pos).normalized()
	var normal: Vector2 = dir.orthogonal() * (width * 0.5)
	var poly := Polygon2D.new()
	poly.color = color
	poly.polygon = PackedVector2Array([
		start_pos + normal,
		end_pos + normal,
		end_pos - normal,
		start_pos - normal,
	])
	return poly

func _make_circle_indicator(center: Vector2, radius: float, color: Color) -> Polygon2D:
	var poly := Polygon2D.new()
	poly.color = color
	var points := PackedVector2Array()
	for i in range(48):
		var a: float = TAU * float(i) / 48.0
		points.append(center + Vector2(cos(a), sin(a)) * radius)
	poly.polygon = points
	return poly

func _distance_to_segment(point: Vector2, start_pos: Vector2, end_pos: Vector2) -> float:
	var segment: Vector2 = end_pos - start_pos
	var len_sq: float = segment.length_squared()
	if len_sq == 0:
		return point.distance_to(start_pos)
	var t: float = clamp((point - start_pos).dot(segment) / len_sq, 0.0, 1.0)
	return point.distance_to(start_pos + segment * t)

func take_damage(amount: int) -> void:
	if current_hp <= 0:
		return
	current_hp -= amount
	VFXManager.hit_particles(global_position, Color.ORANGE_RED)
	VFXManager.damage_number(global_position + Vector2(0, -50), amount, Color(1, 0.8, 0.2))
	hp_bar.value = current_hp
	EventBus.boss_health_changed.emit(current_hp, max_hp)
	if current_hp <= 0:
		_die()

func _die() -> void:
	SoundManager.explosion()
	VFXManager.death_explosion(global_position, Color.RED)
	VFXManager.screen_shake(12.0, 0.5)
	EventBus.boss_defeated.emit()
	queue_free()
