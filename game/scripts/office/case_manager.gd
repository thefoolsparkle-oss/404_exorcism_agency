extends Node

var cases: Dictionary = {}
var current_case_id: String = ""

func _ready() -> void:
	cases = load_json("res://data/cases/approved_cases.json")

func load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("CaseManager: file not found: %s" % path)
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var text: String = file.get_as_text()
	var json: JSON = JSON.new()
	var error: Error = json.parse(text)
	if error != OK:
		push_error("CaseManager: JSON parse error: %s" % json.get_error_message())
		return {}
	return json.data

func get_case(case_id: String) -> Dictionary:
	return cases.get(case_id, {})

func get_all_cases() -> Array:
	var list: Array = []
	for case_id in cases:
		list.append(cases[case_id])
	return list

func select_case(case_id: String) -> void:
	current_case_id = case_id

func get_current_case() -> Dictionary:
	return cases.get(current_case_id, {})
