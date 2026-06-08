extends Area2D

@export var objective_type: String = "collect"
@export var objective_target: String = ""
@export var label_text: String = "物品"
@export var draw_color: Color = Color.YELLOW

enum State { IDLE, DONE }
var state: int = State.IDLE
var player_nearby: bool = false
var disable_progress: float = 0.0
var disable_time: float = 1.5

func _ready() -> void:
	if objective_type == "disable":
		draw_color = Color(0.8, 0.3, 0.9, 0.9)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _draw() -> void:
	if state == State.DONE:
		return
	draw_circle(Vector2.ZERO, 36, draw_color)
	draw_arc(Vector2.ZERO, 44, 0, TAU, 32, Color.WHITE, 2.0, true)
	if objective_type == "disable":
		var bar_w: float = 60
		var bar_h: float = 8
		var bar_y: float = 48
		draw_rect(Rect2(-bar_w/2, bar_y, bar_w, bar_h), Color.BLACK, true)
		draw_rect(Rect2(-bar_w/2, bar_y, bar_w * disable_progress / disable_time, bar_h), Color.GREEN, true)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or state != State.IDLE:
		return
	if objective_type == "collect":
		_activate(body)
	else:
		player_nearby = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		disable_progress = 0.0
		queue_redraw()

func _process(delta: float) -> void:
	if state != State.IDLE or not player_nearby or objective_type != "disable":
		return
	if Input.is_action_pressed("interact"):
		disable_progress += delta
		queue_redraw()
		if disable_progress >= disable_time:
			_activate(null)
	else:
		disable_progress = max(0.0, disable_progress - delta * 2.0)
		queue_redraw()
	rotation += delta * 1.5

func _activate(_body: Node2D) -> void:
	if state != State.IDLE:
		return
	state = State.DONE
	var tracker = get_tree().current_scene.get_node_or_null("objective_tracker")
	if tracker:
		tracker.report_event(objective_type, objective_target, 1)
	queue_free()
