extends Node

enum GameState {
	MAIN_MENU,
	COMBAT_LOADING,
	COMBAT_ACTIVE,
	COMBAT_PAUSED,
	COMBAT_VICTORY,
	COMBAT_DEFEAT
}

var current_state: GameState = GameState.MAIN_MENU

func _ready() -> void:
	EventBus.request_pause.connect(_on_request_pause)
	EventBus.request_resume.connect(_on_request_resume)
	EventBus.request_restart.connect(_on_request_restart)
	EventBus.request_main_menu.connect(_on_request_main_menu)
	EventBus.player_died.connect(_on_player_died)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.combat_started.connect(func():
		change_state(GameState.COMBAT_ACTIVE)
	)

func change_state(new_state: GameState) -> void:
	current_state = new_state
	match new_state:
		GameState.COMBAT_ACTIVE:
			get_tree().paused = false
		GameState.COMBAT_PAUSED:
			get_tree().paused = true
		GameState.COMBAT_VICTORY, GameState.COMBAT_DEFEAT:
			get_tree().paused = true

func _on_request_pause() -> void:
	if current_state == GameState.COMBAT_ACTIVE:
		change_state(GameState.COMBAT_PAUSED)
		EventBus.combat_paused.emit()

func _on_request_resume() -> void:
	if current_state == GameState.COMBAT_PAUSED:
		change_state(GameState.COMBAT_ACTIVE)
		EventBus.combat_resumed.emit()

func _on_request_restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_request_main_menu() -> void:
	change_state(GameState.MAIN_MENU)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/office/office_main.tscn")

func _on_player_died() -> void:
	change_state(GameState.COMBAT_DEFEAT)
	EventBus.combat_ended.emit(false)

func _on_boss_defeated() -> void:
	change_state(GameState.COMBAT_VICTORY)
	EventBus.combat_ended.emit(true)
