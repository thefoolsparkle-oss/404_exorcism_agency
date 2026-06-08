extends CharacterBody2D

@export var max_hp: int = 100
@export var move_speed: float = 200.0

var current_hp: int
var level: int = 1
var experience: int = 0
var experience_to_next: int = 30
var invincible: bool = false
var invincible_timer: float = 0.0
var has_lifesteal: bool = false
var lifesteal_pct: float = 0.0

func _ready() -> void:
	_apply_character_stats()
	EventBus.player_health_changed.emit(current_hp, max_hp)
	$hitbox.body_entered.connect(_on_hitbox_body_entered)

func _apply_character_stats() -> void:
	var char_data: Dictionary = DataLoader.load_json("res://data/characters/characters.json")
	var selected: String = SaveManager.data.selected_character
	var stats: Dictionary = char_data.get(selected, {})
	if stats.is_empty():
		current_hp = max_hp
		return
	if stats.has("max_hp"):
		max_hp = stats.max_hp
	if stats.has("move_speed"):
		move_speed = stats.move_speed
	current_hp = max_hp
	if stats.has("color"):
		$visual.color = Color(stats.color)

	var weapon: Node2D = $weapon_system
	if weapon:
		if stats.has("base_damage"):
			weapon.base_damage = stats.base_damage
			weapon.current_damage = stats.base_damage
		if stats.has("attack_interval"):
			weapon.base_attack_interval = stats.attack_interval
			weapon.current_attack_interval = stats.attack_interval
		if stats.has("attack_range"):
			weapon.attack_range = stats.attack_range
		if stats.has("projectile_speed"):
			weapon.projectile_speed = stats.projectile_speed

func _physics_process(delta: float) -> void:
	if invincible_timer > 0:
		invincible_timer -= delta

	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * move_speed
	move_and_slide()
	global_position.x = clamp(global_position.x, 50, 3790)
	global_position.y = clamp(global_position.y, 50, 2110)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.get("contact_damage"):
		take_damage(body.damage)
	if body.is_in_group("boss"):
		take_damage(body.contact_damage)

func take_damage(amount: int) -> void:
	if invincible:
		return
	current_hp -= amount
	EventBus.player_health_changed.emit(current_hp, max_hp)
	invincible_timer = 0.3
	if current_hp <= 0:
		current_hp = 0
		EventBus.player_died.emit()

func add_experience(amount: int) -> void:
	experience += amount
	while experience >= experience_to_next:
		experience -= experience_to_next
		level += 1
		experience_to_next = _calculate_xp_for_level(level)
		EventBus.request_pause.emit()
		EventBus.player_leveled_up.emit(level)

func _calculate_xp_for_level(lvl: int) -> int:
	return 20 + lvl * 10
