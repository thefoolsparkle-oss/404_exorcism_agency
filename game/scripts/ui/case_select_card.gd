extends Button

signal case_selected(case_id: String)

var case_data: Dictionary = {}

func _ready() -> void:
	text = "%s  Lv.%d" % [case_data.get("display_name", "???"), case_data.get("threat_level", 1)]
	var threat: int = case_data.get("threat_level", 1)
	var color := Color(0.7, 0.9, 0.55)
	match threat:
		1: color = Color(0.6, 0.9, 0.65)
		2: color = Color(0.95, 0.82, 0.35)
		3: color = Color(1.0, 0.55, 0.22)
		_: color = Color(1.0, 0.25, 0.22)
	add_theme_color_override("font_color", color)
	pressed.connect(func(): case_selected.emit(case_data.get("case_id", "")))
