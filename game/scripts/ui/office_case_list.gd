extends Control

var card_scene: PackedScene = preload("res://scenes/ui/case_select_card.tscn")

@onready var case_list: VBoxContainer = $Panel/VBoxContainer/CaseList
@onready var briefing: CanvasLayer = $"../CaseBriefing"

func _ready() -> void:
	visible = false
	briefing.case_confirmed.connect(func(_id): visible = false)
	briefing.case_cancelled.connect(func(): visible = false)
	_populate()

func _populate() -> void:
	for child in case_list.get_children():
		child.queue_free()
	var all_cases: Array = CaseManager.get_all_cases()
	for case_data in all_cases:
		var card: Button = card_scene.instantiate()
		card.case_data = case_data
		card.case_selected.connect(func(cid): _on_case_selected(cid))
		case_list.add_child(card)

func _on_case_selected(case_id: String) -> void:
	visible = false
	CaseManager.select_case(case_id)
	briefing.show_case(case_id)

func _on_close() -> void:
	visible = false
