extends Area2D

@export var experience_amount: int = 10
@export var pickup_speed: float = 400.0
@export var magnet_range: float = 100.0
@export var lifetime: float = 30.0

var being_picked_up: bool = false
var target: Node2D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	var timer: SceneTreeTimer = get_tree().create_timer(lifetime)
	timer.timeout.connect(_fade_out)

func _physics_process(delta: float) -> void:
	if being_picked_up and is_instance_valid(target):
		var dir: Vector2 = (target.global_position - global_position).normalized()
		global_position += dir * pickup_speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		being_picked_up = true
		target = area.get_parent()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SoundManager.pickup()
		body.add_experience(experience_amount)
		EventBus.experience_collected.emit(experience_amount)
		queue_free()

func _fade_out() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
