extends Node

signal objective_updated(index: int, current: int, target: int)
signal all_objectives_complete()

var objectives: Array = []
var progress: Dictionary = {}

func setup(case_data: Dictionary) -> void:
	objectives = case_data.get("objectives", [])
	progress.clear()
	for i in range(objectives.size()):
		progress[i] = 0
	EventBus.boss_defeated.connect(_on_boss_defeated)

func _on_boss_defeated() -> void:
	var current_case: Dictionary = CaseManager.get_current_case()
	var boss_id: String = current_case.get("boss_id", "")
	if not boss_id.is_empty():
		report_event("defeat_boss", boss_id, 1)

func report_event(event_type: String, target: String, count: int = 1) -> void:
	for i in range(objectives.size()):
		var obj: Dictionary = objectives[i]
		if obj.get("type") == event_type and obj.get("target") == target:
			progress[i] = progress.get(i, 0) + count
			var required: int = obj.get("count", 1)
			progress[i] = min(progress[i], required)
			objective_updated.emit(i, progress[i], required)
			_check_completion()

func is_objective_done(index: int) -> bool:
	return progress.get(index, 0) >= objectives[index].get("count", 1)

func are_all_done() -> bool:
	for i in range(objectives.size()):
		if not is_objective_done(i):
			return false
	return true

func _check_completion() -> void:
	if are_all_done():
		all_objectives_complete.emit()

func get_objective_text(index: int) -> String:
	if index < objectives.size():
		var obj: Dictionary = objectives[index]
		return "%s (%d/%d)" % [obj.get("text", ""), progress.get(index, 0), obj.get("count", 1)]
	return ""
