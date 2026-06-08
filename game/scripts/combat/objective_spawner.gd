extends Node2D

var interactive_scene: PackedScene = preload("res://scenes/combat/interactive_object.tscn")
var current_case: Dictionary = {}
var spawn_queue: Array = []
var spawn_timer: float = 0.0
var spawn_interval: float = 8.0
var enabled: bool = false

@onready var spawn_parent: Node2D = $"../interactive_objects"

func _ready() -> void:
	current_case = CaseManager.get_current_case()
	_build_spawn_queue()
	EventBus.combat_started.connect(func(): enabled = true)
	EventBus.combat_ended.connect(func(_v): enabled = false)
	EventBus.combat_paused.connect(func(): enabled = false)
	EventBus.combat_resumed.connect(func(): enabled = true)

func _build_spawn_queue() -> void:
	spawn_queue.clear()
	spawned_count.clear()
	var objectives: Array = current_case.get("objectives", [])
	for obj in objectives:
		var obj_type: String = obj.get("type", "")
		var target: String = obj.get("target", "")
		var count: int = obj.get("count", 0)
		if obj_type == "collect" or obj_type == "disable":
			for i in range(count):
				spawn_queue.append({"type": obj_type, "target": target, "text": obj.get("text", target)})
			spawned_count[target] = 0
	spawn_queue.shuffle()

func _process(delta: float) -> void:
	if not enabled:
		return
	spawn_timer -= delta
	if spawn_timer <= 0 and spawn_queue.size() > 0:
		_spawn_next()
		spawn_timer = spawn_interval

func _spawn_next() -> void:
	if spawn_queue.is_empty():
		return
	var data: Dictionary = spawn_queue.pop_front()
	var obj: Area2D = interactive_scene.instantiate()
	obj.objective_type = data.type
	obj.objective_target = data.target
	obj.label_text = data.text
	obj.global_position = _random_map_position()
	spawn_parent.add_child(obj)

func _random_map_position() -> Vector2:
	var player = get_tree().current_scene.get_node_or_null("entities/player")
	var center: Vector2 = player.global_position if player else Vector2(1920, 1080)
	var angle: float = randf_range(0, TAU)
	var dist: float = randf_range(250, 700)
	var pos: Vector2 = center + Vector2.RIGHT.rotated(angle) * dist
	pos.x = clamp(pos.x, 100, 3740)
	pos.y = clamp(pos.y, 100, 2060)
	return pos
