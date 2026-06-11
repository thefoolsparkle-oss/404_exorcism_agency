extends Node

var passes: int = 0
var fails: int = 0

func _ready() -> void:
	print("START TESTS")
	
	# Data loader
	print("\n--- DataLoader ---")
	var chars = DataLoader.load_json("res://data/characters/characters.json")
	chk(not chars.is_empty(), "chars loaded")
	chk(chars.has("lin_jin"), "has lin_jin")
	
	var skills = DataLoader.load_json("res://data/skills/skills.json")
	chk(not skills.is_empty(), "skills loaded")
	chk(skills.has("red_talisman_pulse"), "has red_talisman_pulse")
	
	var enemies = DataLoader.load_json("res://data/enemies/enemies.json")
	chk(not enemies.is_empty(), "enemies loaded")
	
	var cases = DataLoader.load_json("res://data/cases/approved_cases.json")
	chk(not cases.is_empty(), "cases loaded")
	
	var relics = DataLoader.load_json("res://data/skills/relics.json")
	chk(not relics.is_empty(), "relics loaded")
	
	var narrative = DataLoader.load_json("res://data/narrative/grey_line.json")
	chk(not narrative.is_empty(), "narrative loaded")
	chk(narrative.has("prologue"), "has prologue")
	
	# SaveManager
	print("\n--- SaveManager ---")
	chk(SaveManager != null, "SaveManager exists")
	chk(SaveManager.data.has("prologue_seen"), "has prologue_seen")
	chk(SaveManager.data["prologue_seen"] is bool, "prologue_seen is bool")
	chk(SaveManager.data.has("selected_character"), "has selected_character")
	
	# CaseManager
	print("\n--- CaseManager ---")
	var all = CaseManager.get_all_cases()
	chk(all.size() > 0, "has cases")
	if all.size() > 0:
		var c = all[0]
		if c is Dictionary:
			var cid = c.get("case_id", "")
			chk(cid != "", "has case_id")
			var detail = CaseManager.get_case(cid)
			chk(not detail.is_empty(), "get_case works")
	
	# EventBus
	print("\n--- EventBus ---")
	chk(EventBus != null, "EventBus exists")
	var signal_state := {"fired": false}
	EventBus.experience_dropped.connect(func(_p, _a): signal_state["fired"] = true)
	EventBus.experience_dropped.emit(Vector2.ZERO, 10)
	chk(signal_state["fired"], "signal works")
	
	# Scenes
	print("\n--- Scenes ---")
	
	var player_s = load("res://scenes/combat/player.tscn")
	chk(player_s != null, "player scene loads")
	var p = player_s.instantiate()
	chk(p != null, "player instanced")
	chk(p.max_hp > 0, "player hp > 0")
	chk(p.has_method("take_damage"), "take_damage exists")
	chk(p.has_method("add_experience"), "add_experience exists")
	p.free()
	
	var enemy_s = load("res://scenes/combat/enemies/enemy_base.tscn")
	chk(enemy_s != null, "enemy scene loads")
	var e = enemy_s.instantiate()
	chk(e.has_method("take_damage"), "enemy take_damage")
	chk(e.has_method("_die"), "enemy _die")
	e.free()
	
	var boss_s = load("res://scenes/combat/boss/grey_line_conductor.tscn")
	chk(boss_s != null, "boss scene loads")
	var b = boss_s.instantiate()
	chk(b.has_method("take_damage"), "boss take_damage")
	chk(b.has_method("_die"), "boss _die")
	b.free()
	
	# UI Scenes
	print("\n--- UI Scenes ---")
	
	var narrative_s = load("res://scenes/ui/narrative_screen.tscn")
	chk(narrative_s != null, "narrative loads")
	var n = narrative_s.instantiate()
	chk(n.has_signal("finished"), "narrative has finished")
	chk(n.has_method("show_narrative"), "narrative has show_narrative")
	n.free()
	
	var result_s = load("res://scenes/ui/result_panel.tscn")
	chk(result_s != null, "result panel loads")
	
	var levelup_s = load("res://scenes/ui/level_up_panel.tscn")
	chk(levelup_s != null, "level up loads")
	
	var briefing_s = load("res://scenes/ui/case_briefing.tscn")
	chk(briefing_s != null, "briefing loads")
	var br = briefing_s.instantiate()
	chk(br.has_signal("case_confirmed"), "briefing has case_confirmed")
	chk(br.has_signal("case_cancelled"), "briefing has case_cancelled")
	br.free()
	
	# Sound
	print("\n--- Sound ---")
	chk(SoundManager != null, "SoundManager exists")
	chk(SoundManager._gen_hit_pcm().size() > 0, "hit PCM")
	chk(SoundManager._gen_shoot_pcm().size() > 0, "shoot PCM")
	
	# Asset paths
	print("\n--- Asset Check ---")
	var asset_paths = [
		"res://assets/characters/lin_jin.png",
		"res://assets/bosses/grey_line_conductor.png",
	]
	for ap in asset_paths:
		var fe = FileAccess.file_exists(ap)
		var re = ResourceLoader.exists(ap)
		print("  %s: file=%s resource=%s" % [ap.get_file(), fe, re])
	
	# Game states
	print("\n--- GameManager ---")
	chk(GameManager != null, "GameManager exists")
	var initial = GameManager.current_state
	chk(initial != -1, "current_state valid")
	
	print("\n=== RESULT: %d/%d passed, %d failed ===" % [passes, passes+fails, fails])
	get_tree().quit(0 if fails == 0 else 1)

func chk(cond: bool, msg: String) -> void:
	if cond:
		passes += 1
		print("  PASS: " + msg)
	else:
		fails += 1
		print("  FAIL: " + msg)
