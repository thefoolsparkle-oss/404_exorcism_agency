extends CanvasLayer

@onready var title_label: Label = $panel/vbox/title_label
@onready var stats_label: Label = $panel/vbox/stats_label
@onready var rewards_label: Label = $panel/vbox/rewards_label
@onready var restart_btn: Button = $panel/vbox/restart_button
@onready var quit_btn: Button = $panel/vbox/quit_button

var kill_count: int = 0
var final_level: int = 1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	restart_btn.pressed.connect(_on_restart_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	EventBus.combat_ended.connect(_on_combat_ended)
	EventBus.enemy_killed.connect(func(_t, _p): kill_count += 1)
	EventBus.player_leveled_up.connect(func(lv): final_level = lv)

func _on_combat_ended(victory: bool) -> void:
	var case_id: String = CaseManager.get_current_case().get("case_id", "")
	var has_narrative: bool = case_id.begins_with("GLM-")
	
	if victory:
		title_label.text = "任务完成"
		title_label.add_theme_color_override("font_color", Color.GREEN)
		rewards_label.visible = true
		if has_narrative:
			rewards_label.text = "按 E 阅读后续"
		else:
			rewards_label.text = "案件已完成"
	else:
		title_label.text = "任务失败"
		title_label.add_theme_color_override("font_color", Color.RED)
		rewards_label.visible = false

	var obj_lines: PackedStringArray = ["击杀: %d | 等级: %d" % [kill_count, final_level]]
	var tracker = get_tree().current_scene.get_node_or_null("objective_tracker")
	if tracker:
		obj_lines.append("")
		obj_lines.append("目标完成情况:")
		for i in range(tracker.objectives.size()):
			var mark: String = "✓" if tracker.is_objective_done(i) else "✗"
			obj_lines.append("  %s %s" % [mark, tracker.objectives[i].get("text", "")])
	stats_label.text = "\n".join(obj_lines)
	visible = true
	
	if has_narrative and victory:
		restart_btn.visible = false
		quit_btn.visible = false

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	SaveManager.save()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/office/office_main.tscn")
