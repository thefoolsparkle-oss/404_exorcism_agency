extends CanvasLayer

signal case_confirmed(case_id: String)
signal case_cancelled()

var case_data: Dictionary = {}

@onready var title_label: Label = $panel/vbox/title_label
@onready var threat_label: Label = $panel/vbox/threat_label
@onready var briefing_label: Label = $panel/vbox/briefing_label
@onready var objectives_label: Label = $panel/vbox/objectives_label
@onready var confirm_button: Button = $panel/vbox/hbox/confirm_button
@onready var back_button: Button = $panel/vbox/hbox/back_button

func _ready() -> void:
	visible = false
	confirm_button.pressed.connect(_on_confirm)
	back_button.pressed.connect(_on_back)

func show_case(case_id: String) -> void:
	case_data = CaseManager.get_case(case_id)
	if case_data.is_empty():
		return

	title_label.text = case_data.get("display_name", case_id)
	threat_label.text = "威胁等级: %d | 区域: %s" % [case_data.get("threat_level", 1), case_data.get("district", "")]
	briefing_label.text = case_data.get("briefing", "")

	var obj_text: String = "任务目标:\n"
	for obj in case_data.get("objectives", []):
		obj_text += "  - %s\n" % obj.get("text", "")
	objectives_label.text = obj_text

	visible = true

func _on_confirm() -> void:
	visible = false
	case_confirmed.emit(case_data.get("case_id", ""))

func _on_back() -> void:
	case_cancelled.emit()
