extends Node

var save_path: String = "user://save.json"
var data: Dictionary = {}

func _init() -> void:
	_save_default()

func _ready() -> void:
	_load()

func _load() -> void:
	if not FileAccess.file_exists(save_path):
		_save_default()
		return
	var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
	var text: String = file.get_as_text()
	var json: JSON = JSON.new()
	var error: Error = json.parse(text)
	if error == OK and json.data is Dictionary:
		data = json.data
	_migrate()

func _migrate() -> void:
	if not data.has("prologue_seen"):
		data["prologue_seen"] = false
	if not data.has("ending_seen"):
		data["ending_seen"] = false
	if not data.has("resources"):
		data["resources"] = {"anomaly_essence": 0, "broken_circuit": 0}
	if not data.has("completed_cases"):
		data["completed_cases"] = []
	if not data.has("unlocked_characters"):
		data["unlocked_characters"] = ["lin_jin", "xu_zhaye", "bai_zhi"]
	if not data.has("selected_character"):
		data["selected_character"] = "lin_jin"
	if not data.has("permanent_upgrades"):
		data["permanent_upgrades"] = {}
	var chars: Array = data["unlocked_characters"]
	for c in ["xu_zhaye", "bai_zhi"]:
		if c not in chars:
			chars.append(c)

func _save_default() -> void:
	data = {
		"version": 1,
		"resources": {"anomaly_essence": 0, "broken_circuit": 0},
		"completed_cases": [],
		"unlocked_characters": ["lin_jin", "xu_zhaye", "bai_zhi"],
		"selected_character": "lin_jin",
		"permanent_upgrades": {},
		"prologue_seen": false,
		"ending_seen": false
	}

func save() -> void:
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))

func add_resource(type: String, amount: int) -> void:
	data.resources[type] = data.resources.get(type, 0) + amount

func complete_case(case_id: String) -> void:
	if case_id not in data.completed_cases:
		data.completed_cases.append(case_id)

func is_case_completed(case_id: String) -> bool:
	return case_id in data.completed_cases

func unlock_character(char_id: String) -> void:
	if char_id not in data.unlocked_characters:
		data.unlocked_characters.append(char_id)

func select_character(char_id: String) -> void:
	if char_id in data.unlocked_characters:
		data.selected_character = char_id
