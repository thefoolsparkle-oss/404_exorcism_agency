extends Node2D

func _ready() -> void:
	pass

func _on_start_button_pressed() -> void:
	# TODO: Phase 1.1 — change to combat scene
	get_tree().change_scene_to_file("res://scenes/combat/combat.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
