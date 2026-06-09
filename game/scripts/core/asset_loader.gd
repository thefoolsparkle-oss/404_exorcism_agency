extends Node

static func get_character_sprite(char_id: String) -> Texture2D:
	var path: String = "res://assets/characters/%s.png" % char_id
	if ResourceLoader.exists(path):
		return load(path)
	return null

static func get_enemy_sprite(enemy_id: String) -> Texture2D:
	var path: String = "res://assets/enemies/%s.png" % enemy_id
	if ResourceLoader.exists(path):
		return load(path)
	return null

static func get_boss_sprite(boss_id: String) -> Texture2D:
	var path: String = "res://assets/bosses/%s.png" % boss_id
	if ResourceLoader.exists(path):
		return load(path)
	return null

static func get_background(case_id: String) -> Texture2D:
	var path: String = "res://assets/backgrounds/%s.png" % case_id
	if ResourceLoader.exists(path):
		return load(path)
	path = "res://assets/backgrounds/default.png"
	if ResourceLoader.exists(path):
		return load(path)
	return null
