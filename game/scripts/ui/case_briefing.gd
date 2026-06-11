extends CanvasLayer

signal case_confirmed(case_id: String)
signal case_cancelled()

var case_data: Dictionary = {}
var boss_image: TextureRect

@onready var title_label: Label = $panel/vbox/title_label
@onready var threat_label: Label = $panel/vbox/threat_label
@onready var briefing_label: Label = $panel/vbox/briefing_label
@onready var objectives_label: Label = $panel/vbox/objectives_label
@onready var confirm_button: Button = $panel/vbox/hbox/confirm_button
@onready var back_button: Button = $panel/vbox/hbox/back_button
@onready var vbox: VBoxContainer = $panel/vbox

func _ready() -> void:
	visible = false
	confirm_button.text = "接受任务"
	back_button.text = "返回"
	confirm_button.pressed.connect(_on_confirm)
	back_button.pressed.connect(_on_back)
	_setup_boss_image()
	_style_panel()

func _setup_boss_image() -> void:
	boss_image = TextureRect.new()
	boss_image.custom_minimum_size = Vector2(180, 160)
	boss_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	boss_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vbox.add_child(boss_image)
	vbox.move_child(boss_image, threat_label.get_index() + 1)

func _style_panel() -> void:
	var panel: Panel = $panel
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.075, 0.09, 0.97)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.62, 0.14, 0.12, 1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 14.0
	style.content_margin_top = 14.0
	panel.add_theme_stylebox_override("panel", style)
	title_label.add_theme_color_override("font_color", Color(0.95, 0.14, 0.1))
	threat_label.add_theme_color_override("font_color", Color(0.86, 0.82, 0.72))
	briefing_label.add_theme_color_override("font_color", Color(0.92, 0.9, 0.84))
	objectives_label.add_theme_color_override("font_color", Color(0.92, 0.9, 0.84))

func show_case(case_id: String) -> void:
	case_data = CaseManager.get_case(case_id)
	if case_data.is_empty():
		return
	visible = true
	title_label.text = case_data.get("display_name", case_id)
	threat_label.text = "威胁等级: %d | 区域: %s" % [case_data.get("threat_level", 1), case_data.get("district", "")]
	briefing_label.text = case_data.get("briefing", "")
	boss_image.texture = AssetLoader.get_boss_sprite(case_data.get("boss_id", ""))

	var obj_text: String = "任务目标:\n"
	for obj in case_data.get("objectives", []):
		obj_text += "  - %s\n" % obj.get("text", "")
	objectives_label.text = obj_text

func _on_confirm() -> void:
	visible = false
	case_confirmed.emit(case_data.get("case_id", ""))

func _on_back() -> void:
	visible = false
	case_cancelled.emit()
