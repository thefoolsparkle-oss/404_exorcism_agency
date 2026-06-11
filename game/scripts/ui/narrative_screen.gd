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
var speed_mult: float = 1.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	next_label.text = "E 继续 / Space 跳过"

func show_narrative(title: String, subtitle: String, narrative_lines: Array[String]) -> void:
	title_label.text = title
	subtitle_label.text = subtitle
	lines = narrative_lines
	current_line = 0
	char_index = 0
	display_timer = 0.0
	is_typing = true
	speed_mult = 1.0
	text_label.text = ""
	next_label.visible = false
	visible = true

func _process(delta: float) -> void:
	if not visible:
		return
	if Input.is_action_pressed("interact"):
		speed_mult = 5.0
	else:
		speed_mult = 1.0
	if is_typing and lines.size() > 0:
		display_timer += delta * speed_mult
		if display_timer > 0.03 and current_line < lines.size():
			display_timer = 0.0
			var line: String = lines[current_line]
			if char_index < line.length():
				text_label.text += line[char_index]
				char_index += 1
			else:
				is_typing = false
				next_label.visible = true

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("skip"):
		get_viewport().set_input_as_handled()
		_finish()
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		if is_typing:
			is_typing = false
			next_label.visible = true
			if current_line < lines.size():
				text_label.text = lines[current_line]
			return
		_advance()

func _advance() -> void:
	current_line += 1
	if current_line >= lines.size():
		_finish()
		return
	text_label.text = ""
	char_index = 0
	is_typing = true
	next_label.visible = false

func _finish() -> void:
	visible = false
	finished.emit()
