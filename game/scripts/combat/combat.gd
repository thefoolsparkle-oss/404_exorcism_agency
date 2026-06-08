extends Node2D

func _ready() -> void:
	EventBus.combat_started.emit()
