extends Node2D

static func draw_character(canvas: CanvasItem, pos: Vector2, char_id: String, size: float = 60.0) -> void:
	var s: float = size
	var h: float = s * 0.5
	match char_id:
		"lin_jin":
			canvas.draw_circle(pos, s * 0.22, Color(0.2, 0.5, 0.9))
			canvas.draw_rect(Rect2(pos.x - s * 0.18, pos.y - s * 0.25, s * 0.36, s * 0.45), Color(0.15, 0.4, 0.75), true)
			canvas.draw_circle(pos + Vector2(-s*0.06, -s*0.08), s*0.04, Color.WHITE)
			canvas.draw_circle(pos + Vector2(s*0.06, -s*0.08), s*0.04, Color.WHITE)
			canvas.draw_circle(pos + Vector2(-s*0.06, -s*0.08), s*0.02, Color.BLACK)
			canvas.draw_circle(pos + Vector2(s*0.06, -s*0.08), s*0.02, Color.BLACK)
		"xu_zhaye":
			canvas.draw_circle(pos, s * 0.22, Color(0.7, 0.55, 0.15))
			canvas.draw_rect(Rect2(pos.x - s * 0.18, pos.y - s * 0.25, s * 0.36, s * 0.45), Color(0.55, 0.4, 0.1), true)
			canvas.draw_circle(pos + Vector2(-s*0.06, -s*0.08), s*0.04, Color.WHITE)
			canvas.draw_circle(pos + Vector2(s*0.06, -s*0.08), s*0.04, Color.WHITE)
			canvas.draw_circle(pos + Vector2(-s*0.06, -s*0.08), s*0.02, Color.BLACK)
			canvas.draw_circle(pos + Vector2(s*0.06, -s*0.08), s*0.02, Color.BLACK)
			canvas.draw_arc(pos + Vector2(0, s*0.03), s*0.06, 0, PI, 8, Color(0.4, 0.25, 0.05), 1.5)
		"bai_zhi":
			canvas.draw_circle(pos, s * 0.22, Color(0.7, 0.12, 0.12))
			canvas.draw_rect(Rect2(pos.x - s * 0.18, pos.y - s * 0.25, s * 0.36, s * 0.45), Color(0.5, 0.08, 0.08), true)
			canvas.draw_circle(pos + Vector2(0, -s*0.08), s*0.05, Color.WHITE)
			canvas.draw_circle(pos + Vector2(0, -s*0.08), s*0.025, Color.BLACK)

static func draw_boss(canvas: CanvasItem, pos: Vector2, boss_id: String, size: float = 120.0, time: float = 0.0) -> void:
	var s: float = size
	var pulse: float = 1.0 + sin(time * 4.0) * 0.1
	canvas.draw_circle(pos, s * 0.35 * pulse, Color(0.8, 0.12, 0.08, 0.3))
	canvas.draw_circle(pos, s * 0.28, Color(0.75, 0.1, 0.06))
	canvas.draw_circle(pos, s * 0.15, Color(0.9, 0.15, 0.1))
	canvas.draw_circle(pos + Vector2(-s*0.06, -s*0.05), s*0.07, Color.WHITE)
	canvas.draw_circle(pos + Vector2(s*0.06, -s*0.05), s*0.07, Color.WHITE)
	canvas.draw_circle(pos + Vector2(-s*0.06, -s*0.05), s*0.035, Color.BLACK)
	canvas.draw_circle(pos + Vector2(s*0.06, -s*0.05), s*0.035, Color.BLACK)
	canvas.draw_arc(pos + Vector2(0, s*0.08), s*0.12, 0, PI, 16, Color(0.1, 0, 0), 2.5)
	canvas.draw_circle(pos + Vector2(-s*0.12, s*0.2), s*0.05, Color(0.6, 0.08, 0.05))
	canvas.draw_circle(pos + Vector2(s*0.12, s*0.2), s*0.05, Color(0.6, 0.08, 0.05))
