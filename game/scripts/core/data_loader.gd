extends Node

static func load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("DataLoader: file not found: %s" % path)
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var text: String = file.get_as_text()
	var json: JSON = JSON.new()
	var error: Error = json.parse(text)
	if error != OK:
		push_error("DataLoader: JSON parse error at line %d: %s" % [json.get_error_line(), json.get_error_message()])
		return {}
	return json.data
