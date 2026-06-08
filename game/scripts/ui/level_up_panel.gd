extends CanvasLayer

@onready var card_container: HBoxContainer = $panel/vbox/cards
@onready var panel: Panel = $panel

var skill_card_scene: PackedScene = preload("res://scenes/ui/skill_card.tscn")
var available_choices: Array[String] = []
var skill_data: Dictionary = {}
var acquired_skills: Dictionary = {}

func _ready() -> void:
	visible = false
	skill_data = DataLoader.load_json("res://data/skills/skills.json")
	EventBus.combat_paused.connect(_on_combat_paused)
	EventBus.combat_resumed.connect(func(): visible = false)

func _on_combat_paused() -> void:
	await get_tree().process_frame
	if GameManager.current_state != GameManager.GameState.COMBAT_PAUSED:
		return
	_populate_choices()
	visible = true

func _populate_choices() -> void:
	for child in card_container.get_children():
		child.queue_free()

	var skills: Array = skill_data.keys()
	skills.shuffle()
	available_choices.clear()

	for skill_id in skills:
		if available_choices.size() >= 3:
			break
		if not acquired_skills.has(skill_id):
			available_choices.append(skill_id)
		elif acquired_skills[skill_id] < skill_data[skill_id].max_tier:
			available_choices.append(skill_id)

	while available_choices.size() < 3:
		available_choices.append(skills[randi() % skills.size()])

	for i in range(3):
		var skill_id: String = available_choices[i]
		var card: Panel = skill_card_scene.instantiate()
		card.skill_id = skill_id
		card.skill_data = skill_data[skill_id]
		card.current_tier = acquired_skills.get(skill_id, 0)
		card.selected.connect(_on_skill_selected)
		card.card_index = i + 1
		card_container.add_child(card)

func _on_skill_selected(skill_id: String) -> void:
	var player: Node = get_tree().current_scene.get_node("entities/player")
	var skill_system: Node2D = player.get_node("skill_system")
	if skill_system:
		skill_system.acquire_skill(skill_id)
		acquired_skills = skill_system.acquired_skills
	visible = false
	EventBus.request_resume.emit()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed:
		var idx: int = -1
		if event.keycode == KEY_1:
			idx = 0
		elif event.keycode == KEY_2:
			idx = 1
		elif event.keycode == KEY_3:
			idx = 2
		if idx >= 0 and idx < available_choices.size():
			_on_skill_selected(available_choices[idx])
