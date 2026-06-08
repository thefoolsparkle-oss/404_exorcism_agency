extends Node2D

var characters_data: Dictionary = {}

@onready var terminal_button: Button = $CanvasLayer/TerminalPanel/VBox/terminal_button
@onready var archive_button: Button = $CanvasLayer/TerminalPanel/VBox/archive_button
@onready var char_select: OptionButton = $CanvasLayer/TerminalPanel/VBox/char_select
@onready var resources_label: Label = $CanvasLayer/ResourcesLabel
@onready var briefing: CanvasLayer = $CanvasLayer/CaseBriefing
@onready var case_list_ui: Node2D = $CanvasLayer/CaseListUI

func _ready() -> void:
	characters_data = DataLoader.load_json("res://data/characters/characters.json")
	briefing.case_confirmed.connect(_on_case_confirmed)
	briefing.case_cancelled.connect(_on_case_cancelled)
	_refresh_ui()
	terminal_button.pressed.connect(_open_case_list)
	archive_button.pressed.connect(_open_archive)
	char_select.item_selected.connect(_on_char_selected)
	_populate_characters()

func _refresh_ui() -> void:
	var res: Dictionary = SaveManager.data.resources
	resources_label.text = "异常精华: %d | 破损回路: %d" % [res.get("anomaly_essence", 0), res.get("broken_circuit", 0)]

func _populate_characters() -> void:
	char_select.clear()
	for char_id in SaveManager.data.unlocked_characters:
		var data: Dictionary = characters_data.get(char_id, {})
		char_select.add_item(data.get("name_cn", char_id))
		if char_id == SaveManager.data.selected_character:
			char_select.select(char_select.item_count - 1)

func _on_char_selected(idx: int) -> void:
	var char_ids: Array = SaveManager.data.unlocked_characters
	if idx >= 0 and idx < char_ids.size():
		SaveManager.select_character(char_ids[idx])

func _open_case_list() -> void:
	case_list_ui.visible = true

func _open_archive() -> void:
	pass

func _on_case_confirmed(_case_id: String) -> void:
	SaveManager.save()
	get_tree().change_scene_to_file("res://scenes/combat/combat.tscn")

func _on_case_cancelled() -> void:
	_refresh_ui()

func _on_quit_pressed() -> void:
	SaveManager.save()
	get_tree().quit()
