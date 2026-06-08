extends Node2D

var xp_orb_scene: PackedScene = preload("res://scenes/combat/experience_orb.tscn")
var current_case: Dictionary = {}

@onready var objective_tracker: Node = $objective_tracker

func _ready() -> void:
	current_case = CaseManager.get_current_case()
	objective_tracker.setup(current_case)
	objective_tracker.all_objectives_complete.connect(_on_all_objectives_done)
	EventBus.experience_dropped.connect(_on_experience_dropped)
	EventBus.combat_started.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_show_pause_menu()

func _show_pause_menu() -> void:
	if GameManager.current_state != GameManager.GameState.COMBAT_ACTIVE:
		return
	EventBus.request_pause.emit()
	var popup: AcceptDialog = AcceptDialog.new()
	popup.title = "暂停"
	popup.dialog_text = "是否返回事务所？"
	popup.confirmed.connect(func():
		SaveManager.save()
		EventBus.request_main_menu.emit()
	)
	popup.canceled.connect(func():
		EventBus.request_resume.emit()
	)
	get_tree().current_scene.add_child(popup)
	popup.popup_centered()

func _on_experience_dropped(position: Vector2, amount: int) -> void:
	var orb: Area2D = xp_orb_scene.instantiate()
	orb.global_position = position
	orb.experience_amount = amount
	$experience_orbs.add_child(orb)

func _on_all_objectives_done() -> void:
	get_tree().current_scene.get_node("spawn_director")._spawn_boss()

func get_current_case() -> Dictionary:
	return current_case
