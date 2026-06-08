extends ColorRect

var skill_id: String = ""
var skill_tier: int = 1

func _ready() -> void:
	size = Vector2(48, 48)
	custom_minimum_size = Vector2(48, 48)
	var icon_color: Color = Color.GRAY

	var skill_data: Dictionary = DataLoader.load_json("res://data/skills/skills.json")
	if skill_data.has(skill_id):
		var color_str: String = skill_data[skill_id].get("icon_color", "gray")
		icon_color = Color(color_str)

	color = icon_color

	var tier_label: Label = Label.new()
	tier_label.text = str(skill_tier)
	tier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	tier_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	tier_label.add_theme_font_size_override("font_size", 12)
	tier_label.size = Vector2(48, 48)
	add_child(tier_label)
