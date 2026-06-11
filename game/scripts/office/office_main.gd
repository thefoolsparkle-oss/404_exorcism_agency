extends Node2D

var characters_data: Dictionary = {}
var pending_case_id: String = ""
var active_narrative: String = ""
var character_portrait: TextureRect

@onready var terminal_button: Button = $CanvasLayer/Margin/MainVBox/terminal_button
@onready var archive_button: Button = $CanvasLayer/Margin/MainVBox/archive_button
@onready var char_select: OptionButton = $CanvasLayer/Margin/MainVBox/CharacterSection/char_select
@onready var char_desc: Label = $CanvasLayer/Margin/MainVBox/CharacterSection/char_desc
@onready var character_section: VBoxContainer = $CanvasLayer/Margin/MainVBox/CharacterSection
@onready var resources_label: Label = $CanvasLayer/Margin/MainVBox/ResourcesLabel
@onready var briefing: CanvasLayer = $CanvasLayer/CaseBriefing
@onready var case_list_ui: Control = $CanvasLayer/CaseListUI
@onready var narrative: CanvasLayer = $CanvasLayer/NarrativeScreen

func _ready() -> void:
	characters_data = DataLoader.load_json("res://data/characters/characters.json")
	briefing.case_confirmed.connect(_on_case_confirmed)
	briefing.case_cancelled.connect(_on_case_cancelled)
	narrative.finished.connect(_on_narrative_finished)
	_setup_portrait()
	_localize_static_text()
	_refresh_ui()
	terminal_button.pressed.connect(_open_case_list)
	archive_button.pressed.connect(_open_archive)
	char_select.item_selected.connect(_on_char_selected)
	_populate_characters()

	if not SaveManager.data.prologue_seen:
		await get_tree().create_timer(0.25).timeout
		_show_prologue()
	elif _show_next_unseen_completed_story():
		pass
	elif _all_grey_line_done() and not SaveManager.data.ending_seen:
		_show_ending()

func _localize_static_text() -> void:
	$CanvasLayer/Margin/MainVBox/Title.text = "404 除灵事务所"
	$CanvasLayer/Margin/MainVBox/CharacterSection/CharLabel.text = "选择调查员"
	terminal_button.text = "案件终端"
	archive_button.text = "档案库"
	$CanvasLayer/Margin/MainVBox/QuitButton.text = "退出游戏"
	$CanvasLayer/CaseListUI/Panel/VBoxContainer/Label.text = "选择案件"
	$CanvasLayer/CaseListUI/Panel/VBoxContainer/CloseBtn.text = "关闭"

func _setup_portrait() -> void:
	character_portrait = TextureRect.new()
	character_portrait.custom_minimum_size = Vector2(160, 160)
	character_portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	character_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	character_section.add_child(character_portrait)
	character_section.move_child(character_portrait, char_select.get_index() + 1)

func _show_prologue() -> void:
	var narrative_data: Dictionary = DataLoader.load_json("res://data/narrative/grey_line.json")
	var prologue: Dictionary = narrative_data.get("prologue", {})
	active_narrative = "prologue"
	narrative.show_narrative(prologue.get("title", ""), prologue.get("subtitle", ""), _lines_from_story(prologue))

func _show_ending() -> void:
	var narrative_data: Dictionary = DataLoader.load_json("res://data/narrative/grey_line.json")
	var endings: Dictionary = narrative_data.get("case_complete", {})
	var ending: Dictionary = endings.get("GLM-005", {})
	active_narrative = "ending"
	narrative.show_narrative(ending.get("title", ""), ending.get("subtitle", ""), _lines_from_story(ending))

func _show_case_story(case_id: String) -> bool:
	var story: Dictionary = _get_case_story(case_id)
	if story.is_empty():
		return false
	pending_case_id = case_id
	active_narrative = "case"
	narrative.show_narrative(story.get("title", ""), story.get("subtitle", ""), _lines_from_story(story))
	return true

func _show_next_unseen_completed_story() -> bool:
	for case_id in SaveManager.data.completed_cases:
		var cid := str(case_id)
		if not _has_seen_case_story(cid):
			return _show_case_story(cid)
	return false

func _lines_from_story(story: Dictionary) -> Array[String]:
	var lines_data: Array[String] = []
	for line in story.get("lines", []):
		lines_data.append(str(line))
	return lines_data

func _on_narrative_finished() -> void:
	var finished_narrative: String = active_narrative
	active_narrative = ""
	match finished_narrative:
		"prologue":
			SaveManager.data.prologue_seen = true
			SaveManager.save()
			_show_next_unseen_completed_story()
		"ending":
			SaveManager.data.ending_seen = true
			SaveManager.save()
		"case":
			if pending_case_id != "":
				_mark_case_story_seen(pending_case_id)
				pending_case_id = ""
				if not _show_next_unseen_completed_story() and _all_grey_line_done() and not SaveManager.data.ending_seen:
					_show_ending()
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
		var label: String = "%s - %s" % [data.get("name_cn", char_id), data.get("title", "")]
		char_select.add_item(label)
		if char_id == SaveManager.data.selected_character:
			char_select.select(char_select.item_count - 1)
			_update_character_details(char_id)

func _on_char_selected(idx: int) -> void:
	var char_ids: Array = SaveManager.data.unlocked_characters
	if idx >= 0 and idx < char_ids.size():
		SaveManager.select_character(char_ids[idx])
		_update_character_details(char_ids[idx])

func _update_character_details(char_id: String) -> void:
	var data: Dictionary = characters_data.get(char_id, {})
	char_desc.text = data.get("backstory", data.get("description", ""))
	character_portrait.texture = AssetLoader.get_character_sprite(char_id)

func _open_case_list() -> void:
	case_list_ui.visible = true

func _open_archive() -> void:
	var popup := Window.new()
	popup.title = "案件档案"
	popup.size = Vector2i(920, 620)
	popup.close_requested.connect(popup.queue_free)
	get_tree().current_scene.add_child(popup)

	var root := HBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 16
	root.offset_top = 16
	root.offset_right = -16
	root.offset_bottom = -16
	root.add_theme_constant_override("separation", 14)
	popup.add_child(root)

	var list := VBoxContainer.new()
	list.custom_minimum_size = Vector2(240, 0)
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(list)

	var detail := RichTextLabel.new()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail.fit_content = false
	detail.scroll_active = true
	root.add_child(detail)

	var completed: Array = SaveManager.data.completed_cases
	if completed.is_empty():
		var empty := Label.new()
		empty.text = "暂无完成的案件。"
		list.add_child(empty)
		detail.text = "完成案件后，完整档案和剧情会收录在这里。"
	else:
		for case_id in completed:
			var info: Dictionary = CaseManager.get_case(str(case_id))
			var btn := Button.new()
			btn.text = info.get("display_name", str(case_id))
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.pressed.connect(func(cid = str(case_id), target = detail): target.text = _build_archive_text(cid))
			list.add_child(btn)
		detail.text = _build_archive_text(str(completed[0]))

	popup.popup_centered()

func _build_archive_text(case_id: String) -> String:
	var info: Dictionary = CaseManager.get_case(case_id)
	var story: Dictionary = _get_case_story(case_id)
	var lines: PackedStringArray = []
	lines.append(info.get("display_name", case_id))
	lines.append("")
	lines.append("案件简报")
	lines.append(info.get("briefing", ""))
	lines.append("")
	lines.append("归档记录")
	lines.append(info.get("archive_text", ""))
	if not story.is_empty():
		lines.append("")
		lines.append("完整剧情")
		lines.append(story.get("title", ""))
		if story.get("subtitle", "") != "":
			lines.append(story.get("subtitle", ""))
		for line in story.get("lines", []):
			lines.append(str(line))
	return "\n".join(lines)

func _get_case_story(case_id: String) -> Dictionary:
	var narrative_data: Dictionary = DataLoader.load_json("res://data/narrative/grey_line.json")
	var stories: Dictionary = narrative_data.get("case_complete", {})
	return stories.get(case_id, {})

func _has_seen_case_story(case_id: String) -> bool:
	return case_id in SaveManager.data.get("seen_case_stories", [])

func _mark_case_story_seen(case_id: String) -> void:
	var seen: Array = SaveManager.data.get("seen_case_stories", [])
	if case_id not in seen:
		seen.append(case_id)
		SaveManager.data.seen_case_stories = seen
		SaveManager.save()

func _on_case_confirmed(case_id: String) -> void:
	SaveManager.save()
	_start_case(case_id)

func _start_case(case_id: String) -> void:
	CaseManager.select_case(case_id)
	get_tree().change_scene_to_file("res://scenes/combat/combat.tscn")

func _on_case_cancelled() -> void:
	_refresh_ui()

func _on_quit_pressed() -> void:
	SaveManager.save()
	get_tree().quit()
