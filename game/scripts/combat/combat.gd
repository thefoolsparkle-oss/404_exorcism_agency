extends Node2D

var xp_orb_scene: PackedScene = preload("res://scenes/combat/experience_orb.tscn")

func _ready() -> void:
	EventBus.experience_dropped.connect(_on_experience_dropped)
	EventBus.combat_started.emit()

func _on_experience_dropped(position: Vector2, amount: int) -> void:
	var orb: Area2D = xp_orb_scene.instantiate()
	orb.global_position = position
	orb.experience_amount = amount
	$experience_orbs.add_child(orb)
