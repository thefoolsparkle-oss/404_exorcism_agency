extends Node2D

var selected_case_id: String = ""

@onready var briefing: CanvasLayer = $CaseBriefing
@onready var case_list_container: VBoxContainer = $CanvasLayer/Panel/VBoxContainer/CaseListContainer
@onready var start_button: Button = $CanvasLayer/Panel/VBoxContainer/StartButton
@onready var card_scene: PackedScene = preload("res://scenes/ui/case_select_card.tscn")

func _ready() -> void:
	briefing.case_confirmed.connect(_on_case_confirmed)
	briefing.case_cancelled.connect(_on_case_cancelled)
	_populate_case_list()

func _populate_case_list() -> void:
	for child in case_list_container.get_children():
		child.queue_free()

	var all_cases: Array = CaseManager.get_all_cases()
	for case_data in all_cases:
		var card: Button = card_scene.instantiate()
		card.case_data = case_data
		card.case_selected.connect(_on_case_selected)
		case_list_container.add_child(card)

func _on_case_selected(case_id: String) -> void:
	selected_case_id = case_id
	CaseManager.select_case(case_id)
	briefing.show_case(case_id)

func _on_case_confirmed(_case_id: String) -> void:
	get_tree().change_scene_to_file("res://scenes/combat/combat.tscn")

func _on_case_cancelled() -> void:
	pass

func _on_quit_button_pressed() -> void:
	get_tree().quit()
