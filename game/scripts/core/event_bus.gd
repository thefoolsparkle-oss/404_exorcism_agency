extends Node


signal combat_started()
signal combat_ended(victory: bool)
signal combat_paused()
signal combat_resumed()

signal player_health_changed(current: int, max_hp: int)
signal player_died()
signal player_leveled_up(new_level: int)

signal enemy_spawned(enemy_instance: Node2D)
signal enemy_killed(enemy_type: String, position: Vector2)
signal boss_spawned()
signal boss_health_changed(current: int, max_hp: int)
signal boss_defeated()

signal experience_dropped(position: Vector2, amount: int)
signal experience_collected(amount: int)

signal skill_acquired(skill_id: String, tier: int)

signal request_pause()
signal request_resume()
signal request_restart()
signal request_main_menu()
