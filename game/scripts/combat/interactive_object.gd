extends Area2D

@export var objective_type: String = "collect"
@export var objective_target: String = ""
@export var label_text: String = "物品"

enum State { IDLE, DONE }
var state: int = State.IDLE
var player_nearby: bool = false
var disable_progress: float = 0.0
var disable_time: float = 1.5

@onready var visual: ColorRect = $visual
@onready var label: Label = $label
@onready var progress_bar: ProgressBar = $progress_bar
@onready var prompt_label: Label = $prompt

func _ready() -> void:
	label.text = label_text
	if objective_type == "disable":
		visual.color = Color(0.75, 0.25, 0.85, 0.85)
		prompt_label.text = "按住 E 关闭"
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or state != State.IDLE:
		return
	if objective_type == "collect":
		_activate()
	else:
		player_nearby = true
		prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		prompt_label.visible = false
		disable_progress = 0.0
		progress_bar.value = 0.0
		progress_bar.visible = false

func _process(delta: float) -> void:
	if state != State.IDLE or not player_nearby or objective_type != "disable":
		return
	if Input.is_action_pressed("interact"):
		disable_progress += delta
		progress_bar.visible = true
		progress_bar.value = disable_progress / disable_time * 100
		if disable_progress >= disable_time:
			_activate()
	else:
		disable_progress = max(0.0, disable_progress - delta * 2.0)
		progress_bar.value = disable_progress / disable_time * 100
		if disable_progress <= 0:
			progress_bar.visible = false

func _activate() -> void:
	if state != State.IDLE:
		return
	state = State.DONE
	var tracker = get_tree().current_scene.get_node_or_null("objective_tracker")
	if tracker:
		tracker.report_event(objective_type, objective_target, 1)
	prompt_label.visible = false
	progress_bar.visible = false
	queue_free()
