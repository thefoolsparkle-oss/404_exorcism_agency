extends Button

signal case_selected(case_id: String)

var case_data: Dictionary = {}

func _ready() -> void:
	text = case_data.get("display_name", "???")
	var threat: int = case_data.get("threat_level", 1)
	var color_str: String = "green"
	match threat:
		1: color_str = "green"
		2: color_str = "yellow"
		3: color_str = "orange"
		_: color_str = "red"
	add_theme_color_override("font_color", Color(color_str))
	pressed.connect(func(): case_selected.emit(case_data.get("case_id", "")))
