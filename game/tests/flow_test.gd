extends Node

func _ready() -> void:
	print("FLOW TEST")
	
	# 1. Check prologue state
	print("\n1. Prologue check:")
	print("  prologue_seen = %s" % SaveManager.data["prologue_seen"])
	print("  prologue flag is bool: %s" % str(SaveManager.data["prologue_seen"] is bool))
	
	# 2. Case selection flow  
	print("\n2. Case flow:")
	CaseManager.select_case("GLM-001")
	var cur = CaseManager.get_current_case()
	print("  selected: %s" % cur.get("case_id", "FAIL"))
	print("  has objectives: %s" % str(cur.get("objectives", []).size() > 0))
	print("  has boss_id: %s" % cur.get("boss_id", "NONE"))
	
	# 3. Victory flow: boss dies -> combat_ended
	print("\n3. Victory flow:")
	print("  initial state: %d" % GameManager.current_state)
	GameManager.change_state(GameManager.GameState.COMBAT_VICTORY)
	print("  after change_state(VICTORY): paused=%s state=%d" % [get_tree().paused, GameManager.current_state])
	
	# Simulate combat_ended
	EventBus.combat_ended.emit(true)
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 4. Narrative test
	print("\n4. Narrative screen:")
	var narrative_s = load("res://scenes/ui/narrative_screen.tscn")
	var n = narrative_s.instantiate()
	print("  process_mode=%d (ALWAYS=%d)" % [n.process_mode, Node.PROCESS_MODE_ALWAYS])
	print("  initial visible=%s" % n.visible)
	
	# Simulate show_narrative during victory
	get_tree().current_scene.add_child(n)
	await get_tree().process_frame
	print("  ready visible=%s (should be false)" % n.visible)
	print("  ready process_mode=%d (should be %d)" % [n.process_mode, Node.PROCESS_MODE_ALWAYS])
	
	var test_lines: Array[String] = ["Line 1", "Line 2"]
	n.show_narrative("Test", "", test_lines)
	await get_tree().process_frame
	print("  after show: visible=%s is_typing=%s" % [n.visible, n.is_typing])
	
	# Simulate E press (non-typing -> advance)
	n.is_typing = false
	n._advance()
	await get_tree().process_frame
	print("  after advance1: current=%d is_typing=%s" % [n.current_line, n.is_typing])
	
	n.is_typing = false
	n._advance()
	await get_tree().process_frame
	print("  after advance2: visible=%s (should be false)" % n.visible)
	
	# 5. Result panel test
	print("\n5. Result panel:")
	var result_s = load("res://scenes/ui/result_panel.tscn")
	var r = result_s.instantiate()
	print("  process_mode=%d (ALWAYS=%d)" % [r.process_mode, Node.PROCESS_MODE_ALWAYS])
	print("  restart_btn: %s" % str(r.get_node_or_null("panel/vbox/restart_button") != null))
	print("  quit_btn: %s" % str(r.get_node_or_null("panel/vbox/quit_button") != null))
	r.free()
	
	print("\nDONE")
	get_tree().quit()
