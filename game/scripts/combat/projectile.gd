extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 400.0
var damage: int = 10
var pierce_remaining: int = 0
var lifetime: float = 3.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var timer: SceneTreeTimer = get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	var pos: Vector2 = global_position
	if pos.x < 0 or pos.x > 3840 or pos.y < 0 or pos.y > 2160:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") or body.is_in_group("boss"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		if pierce_remaining <= 0:
			queue_free()
		else:
			pierce_remaining -= 1
