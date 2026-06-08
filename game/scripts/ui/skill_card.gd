extends Panel

signal selected(skill_id: String)

var skill_id: String = ""
var skill_data: Dictionary = {}
var current_tier: int = 0
var card_index: int = 1

@onready var name_label: Label = $vbox/name_label
@onready var desc_label: Label = $vbox/desc_label
@onready var key_hint: Label = $vbox/key_hint
@onready var icon: ColorRect = $vbox/icon
@onready var tier_label: Label = $vbox/tier_label

func _ready() -> void:
	name_label.text = skill_data.get("name_cn", skill_id)
	key_hint.text = "按 %d 选择" % card_index
	var icon_color_str: String = skill_data.get("icon_color", "gray")
	icon.color = Color(icon_color_str)

	if current_tier == 0:
		desc_label.text = skill_data.get("description_cn", "")
		tier_label.text = "新技能"
	else:
		desc_label.text = skill_data.get("description_cn", "") + "\n（升级至 Tier %d）" % (current_tier + 1)
		tier_label.text = "Tier %d → %d" % [current_tier, current_tier + 1]

	gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		selected.emit(skill_id)
