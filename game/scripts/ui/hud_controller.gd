extends CanvasLayer

@onready var hp_bar: ProgressBar = $hp_panel/vbox_hp/hp_bar
@onready var hp_text: Label = $hp_panel/vbox_hp/hp_text
@onready var xp_bar: ProgressBar = $xp_panel/vbox_xp/xp_bar
@onready var xp_text: Label = $xp_panel/vbox_xp/xp_text
@onready var level_label: Label = $xp_panel/vbox_xp/level_label
@onready var timer_label: Label = $timer_label
@onready var boss_hp: ProgressBar = $boss_hp
@onready var skill_icons: HBoxContainer = $skill_icons

var skill_scene: PackedScene = preload("res://scenes/ui/skill_icon.tscn")

func _ready() -> void:
	EventBus.player_health_changed.connect(_on_player_health_changed)
	EventBus.player_leveled_up.connect(_on_player_level_up)
	EventBus.boss_spawned.connect(func(): boss_hp.visible = true)
	EventBus.boss_health_changed.connect(_on_boss_health_changed)
	EventBus.skill_acquired.connect(_on_skill_acquired)
	EventBus.combat_started.connect(_on_combat_started)
	boss_hp.visible = false

func _on_combat_started() -> void:
	boss_hp.visible = false
	for child in skill_icons.get_children():
		child.queue_free()

func _process(_delta: float) -> void:
	if GameManager.current_state == GameManager.GameState.COMBAT_ACTIVE:
		var spawn_dir = get_tree().current_scene.get_node_or_null("spawn_director")
		if spawn_dir:
			timer_label.text = "%.0fs" % spawn_dir.game_timer

	var player = get_tree().current_scene.get_node_or_null("entities/player")
	if player:
		xp_bar.max_value = player.experience_to_next
		xp_bar.value = player.experience
		xp_text.text = "%d/%d" % [player.experience, player.experience_to_next]

func _on_player_health_changed(current: int, max_val: int) -> void:
	hp_bar.max_value = max_val
	hp_bar.value = current
	hp_text.text = "%d/%d" % [current, max_val]
	if float(current) / float(max_val) < 0.3:
		hp_text.add_theme_color_override("font_color", Color.RED)
	else:
		hp_text.add_theme_color_override("font_color", Color.WHITE)

func _on_player_level_up(new_level: int) -> void:
	level_label.text = "Lv.%d" % new_level

func _on_boss_health_changed(current: int, max_val: int) -> void:
	boss_hp.max_value = max_val
	boss_hp.value = current

func _on_skill_acquired(skill_id: String, tier: int) -> void:
	var icon: ColorRect = skill_scene.instantiate()
	icon.skill_id = skill_id
	icon.skill_tier = tier
	skill_icons.add_child(icon)
