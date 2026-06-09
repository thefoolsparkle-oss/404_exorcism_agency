extends CharacterBody2D

@export var max_hp: int = 500
@export var move_speed: float = 100.0
@export var contact_damage: int = 30

var current_hp: int
var phase: int = 1
var enraged: bool = false

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
	_chase_player()
	move_and_slide()
	var pulse: float = 1.0 + sin(Time.get_ticks_msec() * 0.004) * 0.15
	visual.modulate = Color(enraged and 1.0 or 0.85, 0.25, 0.2, 1) * pulse

func _update_phase() -> void:
	var hp_percent: float = float(current_hp) / float(max_hp)
	if hp_percent <= 0.3:
		phase = 3
		if not enraged:
			enraged = true
			move_speed *= 1.5
			ticket_punch_cooldown *= 0.7
			boss_label.text = "BOSS (暴怒)"
	elif hp_percent <= 0.6:
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
	var indicator: ColorRect = ColorRect.new()
	indicator.color = Color(1, 0, 0, 0.3)
	indicator.size = Vector2(300, 60)
	indicator.global_position = global_position - Vector2(150, 30)
	indicator.rotation = dash_dir.angle()
	get_tree().current_scene.add_child(indicator)
	var tw: Tween = create_tween()
	tw.tween_interval(0.6)
	tw.tween_callback(func():
		indicator.queue_free()
		var dash_tw: Tween = create_tween()
		var target_pos: Vector2 = global_position + dash_dir * 300
		dash_tw.tween_property(self, "global_position", target_pos, 0.25)
		dash_tw.tween_callback(func():
			if player.global_position.distance_to(global_position) < 90:
				player.take_damage(contact_damage * 2)
		)
	)

func _summon_passengers() -> void:
	var count: int = 1
	for i in range(count):
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
	var indicator: ColorRect = ColorRect.new()
	indicator.color = Color(0.5, 0, 0.5, 0.3)
	indicator.size = Vector2(radius * 2, radius * 2)
	indicator.global_position = global_position - Vector2(radius, radius)
	get_tree().current_scene.add_child(indicator)
	var tw: Tween = create_tween()
	tw.tween_interval(0.8)
	tw.tween_callback(func():
		indicator.queue_free()
		if player.global_position.distance_to(global_position) <= radius:
			player.take_damage(20)
			var original_speed: float = player.move_speed
			player.move_speed *= 0.5
			get_tree().create_timer(2.0).timeout.connect(func(): player.move_speed = original_speed)
	)

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
	var tw: Tween = create_tween()
	tw.tween_property(visual, "modulate:a", 0.0, 0.5)
	tw.tween_callback(queue_free)
