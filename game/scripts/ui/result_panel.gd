extends CanvasLayer

@onready var title_label: Label = $panel/vbox/title_label
@onready var stats_label: Label = $panel/vbox/stats_label

var kill_count: int = 0
var final_level: int = 1

func _ready() -> void:
	visible = false
	EventBus.combat_ended.connect(_on_combat_ended)
	EventBus.enemy_killed.connect(func(_t, _p): kill_count += 1)
	EventBus.player_leveled_up.connect(func(lv): final_level = lv)

func _on_combat_ended(victory: bool) -> void:
	if victory:
		title_label.text = "任务完成"
		title_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		title_label.text = "任务失败"
		title_label.add_theme_color_override("font_color", Color.RED)

	stats_label.text = "击杀: %d | 等级: %d" % [kill_count, final_level]
	visible = true

func _on_restart_pressed() -> void:
	EventBus.request_restart.emit()

func _on_quit_pressed() -> void:
	EventBus.request_main_menu.emit()
