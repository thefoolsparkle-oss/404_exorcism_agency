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
	$visual.visible = false

func _draw() -> void:
	var tex: Texture2D = AssetLoader.get_enemy_sprite(enemy_id)
	if tex:
		var draw_size: float = max(enemy_size * 1.8, 48.0)
		draw_texture_rect(tex, Rect2(Vector2(-draw_size / 2.0, -draw_size * 0.65), Vector2(draw_size, draw_size)), false)
		return
	var s: float = enemy_size
	var c: Color = enemy_color
	match enemy_id:
		"shadow_fragment":
			draw_circle(Vector2.ZERO, s / 2, Color(0.15, 0.05, 0.15, 0.8))
			draw_circle(Vector2.ZERO, s / 3, Color(0.3, 0.1, 0.3, 0.6))
		"mirror_clone":
			draw_rect(Rect2(-s/2, -s/2, s, s), Color(c, 0.6), true)
			draw_rect(Rect2(-s/3, -s/3, s*2/3, s*2/3), Color.WHITE, false, 1.5)
		"charmed_passenger":
			draw_circle(Vector2.ZERO, s / 2, c)
			draw_arc(Vector2.ZERO, s / 2 + 3, rotation, PI + rotation, 8, Color.WHITE, 1.5)
		"time_echo":
			draw_rect(Rect2(-s/2, -s/2, s, s), Color(c, 0.5), true)
			draw_rect(Rect2(-s/2 + 4, -s/2 + 4, s - 8, s - 8), Color(c, 0.3), true)
		"paper_bird":
			var pts: PackedVector2Array = [Vector2(0, -s/2), Vector2(s/3, s/6), Vector2(0, 0), Vector2(-s/3, s/6)]
			draw_polygon(pts, [Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE])
			draw_circle(Vector2(0, -s/4), s/12, Color(0, 0, 0, 0.6))
		"alley_cat":
			draw_circle(Vector2(0, 0), s/2.5, Color(c, 0.7))
			draw_circle(Vector2(s/5, -s/6), s/8, Color.DARK_GREEN)
			draw_circle(Vector2(-s/5, -s/6), s/8, Color.DARK_GREEN)
			draw_circle(Vector2(s/5, -s/6), s/16, Color.BLACK)
			draw_circle(Vector2(-s/5, -s/6), s/16, Color.BLACK)
		"incense_doll":
			draw_rect(Rect2(-s/3, -s/3, s*2/3, s*2/3), Color.WHITE_SMOKE, true)
			draw_rect(Rect2(-s/4, -s/4, s/2, s/2), Color(c), true)
			draw_circle(Vector2(0, -s/6), s/10, Color(0.8, 0.2, 0.2))
			draw_circle(Vector2(-s/5, -s/4), s/14, Color.BLACK)
			draw_circle(Vector2(s/5, -s/4), s/14, Color.BLACK)
		"night_walker":
			draw_rect(Rect2(-s/3, -s/2, s*2/3, s), Color(c, 0.85), true)
			draw_circle(Vector2(0, -s/3), s/6, Color(c, 0.5))
			draw_circle(Vector2(-s/6, -s/3), s/16, Color.RED)
			draw_circle(Vector2(s/6, -s/3), s/16, Color.RED)
		_:
			if contact_damage:
				var pts: PackedVector2Array = [Vector2(0, -s/2), Vector2(-s/2, s/2), Vector2(s/2, s/2)]
				draw_polygon(pts, [c])
			else:
				draw_circle(Vector2.ZERO, s / 2, c)
				draw_arc(Vector2.ZERO, s / 2 + 2, 0, TAU, 16, Color.WHITE, 1.5)

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
	var dir_to_player: Vector2 = (player.global_position - global_position).normalized()
	var behind: Vector2 = player.global_position - dir_to_player * 80.0
	global_position = behind

func _shoot(direction: Vector2) -> void:
	var proj: Area2D = projectile_scene.instantiate()
	proj.global_position = global_position
	proj.direction = direction
	proj.speed = projectile_speed
	proj.damage = damage
	var proj_container := get_tree().current_scene.get_node_or_null("projectiles")
	if proj_container:
		proj_container.add_child(proj)

func take_damage(amount: int) -> void:
	if current_hp <= 0:
		return
	current_hp -= amount
	VFXManager.hit_particles(global_position, Color.RED)
	VFXManager.damage_number(global_position + Vector2(0, -30), amount, Color(1, 0.5, 0.5))
	queue_redraw()
	if current_hp <= 0:
		_die()

func _die() -> void:
	SoundManager.hit()
	VFXManager.death_explosion(global_position, Color(enemy_color))
	EventBus.enemy_killed.emit(enemy_id, global_position)
	EventBus.experience_dropped.emit(global_position, experience_drop)
	queue_free()
