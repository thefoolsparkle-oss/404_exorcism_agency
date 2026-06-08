extends Node2D

var characters_data: Dictionary = {}

@onready var terminal_button: Button = $CanvasLayer/Margin/MainVBox/terminal_button
@onready var archive_button: Button = $CanvasLayer/Margin/MainVBox/archive_button
@onready var char_select: OptionButton = $CanvasLayer/Margin/MainVBox/CharacterSection/char_select
@onready var char_desc: Label = $CanvasLayer/Margin/MainVBox/CharacterSection/char_desc
@onready var resources_label: Label = $CanvasLayer/Margin/MainVBox/ResourcesLabel
@onready var briefing: CanvasLayer = $CanvasLayer/CaseBriefing
@onready var case_list_ui: Control = $CanvasLayer/CaseListUI
@onready var narrative: CanvasLayer = $CanvasLayer/NarrativeScreen

func _ready() -> void:
	characters_data = DataLoader.load_json("res://data/characters/characters.json")
	briefing.case_confirmed.connect(_on_case_confirmed)
	briefing.case_cancelled.connect(_on_case_cancelled)
	narrative.finished.connect(_on_narrative_finished)
	_refresh_ui()
	terminal_button.pressed.connect(_open_case_list)
	archive_button.pressed.connect(_open_archive)
	char_select.item_selected.connect(_on_char_selected)
	_populate_characters()
	
	if not SaveManager.data.prologue_seen:
		_show_prologue()
	elif _all_grey_line_done() and not SaveManager.data.ending_seen:
		_show_ending()

func _show_prologue() -> void:
	var narrative_data: Dictionary = DataLoader.load_json("res://data/narrative/grey_line.json")
	var prologue: Dictionary = narrative_data.get("prologue", {})
	narrative.show_narrative(prologue.get("title", ""), prologue.get("subtitle", ""), prologue.get("lines", []))

func _show_ending() -> void:
	var narrative_data: Dictionary = DataLoader.load_json("res://data/narrative/grey_line.json")
	var endings: Dictionary = narrative_data.get("case_complete", {})
	var ending: Dictionary = endings.get("GLM-005", {})
	narrative.show_narrative(ending.get("title", ""), "", ending.get("lines", []))

func _on_narrative_finished() -> void:
	if not SaveManager.data.prologue_seen:
		SaveManager.data.prologue_seen = true
	elif _all_grey_line_done() and not SaveManager.data.ending_seen:
		SaveManager.data.ending_seen = true
	SaveManager.save()

func _all_grey_line_done() -> bool:
	for i in range(1, 6):
		var cid: String = "GLM-%03d" % i
		if cid not in SaveManager.data.completed_cases:
			return false
	return true

func _refresh_ui() -> void:
	var res: Dictionary = SaveManager.data.resources
	resources_label.text = "异常精华: %d | 破损回路: %d" % [res.get("anomaly_essence", 0), res.get("broken_circuit", 0)]

func _populate_characters() -> void:
	char_select.clear()
	for char_id in SaveManager.data.unlocked_characters:
		var data: Dictionary = characters_data.get(char_id, {})
		var label: String = "%s — %s" % [data.get("name_cn", char_id), data.get("title", "")]
		char_select.add_item(label)
		if char_id == SaveManager.data.selected_character:
			char_select.select(char_select.item_count - 1)
			char_desc.text = data.get("backstory", "")

func _on_char_selected(idx: int) -> void:
	var char_ids: Array = SaveManager.data.unlocked_characters
	if idx >= 0 and idx < char_ids.size():
		SaveManager.select_character(char_ids[idx])
		var data: Dictionary = characters_data.get(char_ids[idx], {})
		char_desc.text = data.get("backstory", "")

func _open_case_list() -> void:
	case_list_ui.visible = true

func _open_archive() -> void:
	var popup: AcceptDialog = AcceptDialog.new()
	popup.title = "案件档案"
	var text: String = ""
	var case_data: Dictionary = DataLoader.load_json("res://data/cases/approved_cases.json")
	for case_id in SaveManager.data.completed_cases:
		var info: Dictionary = case_data.get(case_id, {})
		text += "■ %s\n%s\n\n" % [info.get("display_name", case_id), info.get("archive_text", "")]
	if text == "":
		text = "暂无完成的案件。"
	popup.dialog_text = text
	get_tree().current_scene.add_child(popup)
	popup.popup_centered()

func _on_case_confirmed(_case_id: String) -> void:
	SaveManager.save()
	get_tree().change_scene_to_file("res://scenes/combat/combat.tscn")

func _on_case_cancelled() -> void:
	_refresh_ui()

func _on_quit_pressed() -> void:
	SaveManager.save()
	get_tree().quit()
