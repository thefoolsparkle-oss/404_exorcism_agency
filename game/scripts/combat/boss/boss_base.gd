extends CharacterBody2D

@export var max_hp: int = 300
@export var move_speed: float = 80.0
@export var contact_damage: int = 20

var current_hp: int
var phase: int = 1
var enraged: bool = false
var is_casting: bool = false
var boss_name: String = "BOSS"
var player: CharacterBody2D
var boss_id: String = "grey_line_conductor"
var enemy_scene: PackedScene = preload("res://scenes/combat/enemies/enemy_base.tscn")
var enemy_data: Dictionary = {}

@onready var visual: ColorRect = $visual
@onready var hp_bar: ProgressBar = $boss_hp_bar
@onready var boss_label: Label = $boss_label

func _ready() -> void:
	current_hp = max_hp
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	boss_label.text = boss_name
	enemy_data = DataLoader.load_json("res://data/enemies/enemies.json")
	_init_boss()

func _init_boss() -> void:
	pass

func set_player_ref(p: CharacterBody2D) -> void:
	player = p

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	_update_phase()
	_update_boss_cooldowns(delta)
	if not is_casting:
		_chase_player()
		move_and_slide()
	else:
		velocity = Vector2.ZERO
	queue_redraw()

func _update_boss_cooldowns(_delta: float) -> void:
	pass

func _draw() -> void:
	var tex: Texture2D = AssetLoader.get_boss_sprite(boss_id)
	if tex:
		draw_texture_rect(tex, Rect2(Vector2(-78, -110), Vector2(156, 156)), false)
	else:
		SpriteDrawer.draw_boss(self, Vector2.ZERO, boss_id, 120.0, Time.get_ticks_msec() * 0.001)

func _update_phase() -> void:
	var hp_percent: float = float(current_hp) / float(max_hp)
	if hp_percent <= 0.3 and phase < 3:
		phase = 3
		if not enraged:
			enraged = true
			_on_enrage()
	elif hp_percent <= 0.6 and phase < 2:
		phase = 2

func _on_enrage() -> void:
	move_speed *= 1.4
	boss_label.text = boss_name + " (暴怒)"

func _chase_player() -> void:
	var dir: Vector2 = (player.global_position - global_position).normalized()
	velocity = dir * move_speed

func _spawn_enemy(enemy_id: String, count: int = 1) -> void:
	for _i in range(count):
		var enemy: CharacterBody2D = enemy_scene.instantiate()
		enemy.enemy_id = enemy_id
		var data: Dictionary = enemy_data.get(enemy_id, {})
		enemy.max_hp = data.get("hp", 20)
		enemy.move_speed = data.get("move_speed", 120.0)
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
		enemy.global_position = global_position + Vector2(randf_range(-150, 150), randf_range(-150, 150))
		get_tree().current_scene.get_node("entities/enemies").add_child(enemy)

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
