extends "res://scripts/combat/boss/boss_base.gd"

var shard_cooldown: float = 2.5
var shard_timer: float = 1.0
var clone_cooldown: float = 7.0
var clone_timer: float = 3.0
var clones: Array[Node2D] = []

func _init_boss() -> void:
	boss_name = "镜中守护者"

func _on_enrage() -> void:
	move_speed *= 1.5
	shard_cooldown *= 0.7
	clone_cooldown *= 0.7

func _update_boss_cooldowns(delta: float) -> void:
	shard_timer -= delta
	clone_timer -= delta
	if shard_timer <= 0:
		_mirror_shard()
		shard_timer = shard_cooldown
	if clone_timer <= 0:
		_spawn_clone()
		clone_timer = clone_cooldown
	_cleanup_clones()

func _mirror_shard() -> void:
	var proj_scene: PackedScene = preload("res://scenes/combat/enemy_projectile.tscn")
	var dir: Vector2 = (player.global_position - global_position).normalized()
	var count: int = 3 if phase >= 2 else 1
	var spread: float = deg_to_rad(20.0)
	for i in range(count):
		var proj: Area2D = proj_scene.instantiate()
		proj.global_position = global_position
		proj.direction = dir.rotated((i - (count - 1) / 2.0) * spread)
		proj.speed = 220.0
		proj.damage = 12
		get_tree().current_scene.get_node_or_null("projectiles")?.add_child(proj)

func _spawn_clone() -> void:
	var max_clones: int = 2 if phase >= 3 else 1
	if clones.size() >= max_clones:
		return
	var clone: Node2D = Node2D.new()
	clone.name = "mirror_clone"
	add_child(clone)
	var visual: ColorRect = ColorRect.new()
	visual.color = Color(0.7, 0.7, 0.8, 0.4)
	visual.size = Vector2(80, 80)
	visual.position = Vector2(-40, -40)
	clone.add_child(visual)
	clone.global_position = global_position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
	clones.append(clone)

func _cleanup_clones() -> void:
	for clone in clones:
		if not is_instance_valid(clone):
			continue
		clone.global_position = clone.global_position.move_toward(player.global_position, 60.0 * 0.016)
		if clone.global_position.distance_to(player.global_position) < 40:
			player.take_damage(contact_damage / 2)
			clone.queue_free()

func _physics_process(delta: float) -> void:
	super(delta)
	_cleanup_clones()

func _die() -> void:
	for clone in clones:
		if is_instance_valid(clone):
			clone.queue_free()
	clones.clear()
	super._die()
