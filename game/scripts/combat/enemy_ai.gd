extends CharacterBody2D

@export var enemy_id: String = ""
@export var max_hp: int = 30
@export var move_speed: float = 100.0
@export var damage: int = 10
@export var contact_damage: bool = true
@export var attack_range: float = 0.0
@export var attack_cooldown: float = 0.0
@export var projectile_speed: float = 200.0
@export var experience_drop: int = 10
@export var enemy_color: Color = Color.DIM_GRAY
@export var enemy_size: float = 30.0
@export var has_special: String = ""
@export var teleport_cooldown: float = 3.0

var current_hp: int
var attack_timer: float = 0.0
var teleport_timer: float = 0.0
var projectile_scene: PackedScene = preload("res://scenes/combat/enemy_projectile.tscn")
var player: CharacterBody2D

func _ready() -> void:
	current_hp = max_hp
	$visual.color = enemy_color
	$visual.size = Vector2(enemy_size, enemy_size)
	$visual.position = Vector2(-enemy_size / 2.0, -enemy_size / 2.0)
	var shape: CircleShape2D = $collision_shape.shape
	shape.radius = enemy_size / 2.0
	teleport_timer = teleport_cooldown * 0.5

func set_player_ref(p: CharacterBody2D) -> void:
	player = p

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	var direction: Vector2 = (player.global_position - global_position).normalized()
	var distance: float = global_position.distance_to(player.global_position)

	if has_special == "teleport":
		teleport_timer -= delta
		if teleport_timer <= 0:
			_teleport_behind_player()
			teleport_timer = teleport_cooldown

	if contact_damage:
		velocity = direction * move_speed
	else:
		if distance > attack_range * 1.2:
			velocity = direction * move_speed
		elif distance < attack_range * 0.5:
			velocity = -direction * move_speed * 0.5
		else:
			velocity = Vector2.ZERO
			attack_timer -= delta
			if attack_timer <= 0:
				_shoot(direction)
				attack_timer = attack_cooldown

	move_and_slide()

func _teleport_behind_player() -> void:
	var behind: Vector2 = player.global_position
	var dir_to_player: Vector2 = (player.global_position - global_position).normalized()
	if dir_to_player.length() > 0:
		behind = player.global_position - dir_to_player * 80.0
	global_position = behind

func _shoot(direction: Vector2) -> void:
	var proj: Area2D = projectile_scene.instantiate()
	proj.global_position = global_position
	proj.direction = direction
	proj.speed = projectile_speed
	proj.damage = damage
	get_tree().current_scene.get_node("projectiles").add_child(proj)

func take_damage(amount: int) -> void:
	current_hp -= amount
	var flash_tween: Tween = create_tween()
	flash_tween.tween_property($visual, "modulate", Color.RED, 0.1)
	flash_tween.tween_property($visual, "modulate", Color.WHITE, 0.1)
	if current_hp <= 0:
		_die()

func _die() -> void:
	EventBus.enemy_killed.emit(enemy_id, global_position)
	EventBus.experience_dropped.emit(global_position, experience_drop)
	queue_free()
