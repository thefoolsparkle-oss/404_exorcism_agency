extends Node

var save_path: String = "user://save.json"

var data: Dictionary = {
	"version": 1,
	"resources": {
		"anomaly_essence": 0,
		"broken_circuit": 0
	},
	"completed_cases": [],
	"unlocked_characters": ["lin_jin"],
	"selected_character": "lin_jin",
	"permanent_upgrades": {}
}

func _ready() -> void:
	_load()

func _load() -> void:
	if not FileAccess.file_exists(save_path):
		return
	var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
	var text: String = file.get_as_text()
	var json: JSON = JSON.new()
	var error: Error = json.parse(text)
	if error == OK and json.data is Dictionary:
		data = json.data

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
