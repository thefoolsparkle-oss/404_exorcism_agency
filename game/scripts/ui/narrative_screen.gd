extends CanvasLayer

signal finished()

@onready var title_label: Label = $dim/center/title
@onready var subtitle_label: Label = $dim/center/subtitle
@onready var text_label: Label = $dim/center/text
@onready var next_label: Label = $dim/center/next_hint

var lines: Array[String] = []
var current_line: int = 0
var char_index: int = 0
var display_timer: float = 0.0
var is_typing: bool = true
var can_advance: bool = false

func show_narrative(title: String, subtitle: String, narrative_lines: Array) -> void:
	title_label.text = title
	subtitle_label.text = subtitle
	lines = narrative_lines
	current_line = 0
	char_index = 0
	display_timer = 0.0
	is_typing = true
	can_advance = false
	text_label.text = ""
	next_label.visible = false
	visible = true

func _process(delta: float) -> void:
	if not visible:
		return
	if is_typing:
		display_timer += delta
		if display_timer > 0.03 and current_line < lines.size():
			display_timer = 0.0
			var line: String = lines[current_line]
			if char_index < line.length():
				text_label.text += line[char_index]
				char_index += 1
			else:
				is_typing = false
				can_advance = true
				next_label.visible = true
	if can_advance and Input.is_action_just_pressed("interact"):
		_advance()

func _advance() -> void:
	current_line += 1
	if current_line >= lines.size():
		visible = false
		finished.emit()
		return
	text_label.text = ""
	char_index = 0
	is_typing = true
	can_advance = false
	next_label.visible = false
