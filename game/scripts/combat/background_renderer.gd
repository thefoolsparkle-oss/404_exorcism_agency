extends Node2D

var case_district: String = "metro"
var time: float = 0.0
var bg_color: Color = Color(0.05, 0.05, 0.08)
var image_tex: Texture2D

func _ready() -> void:
	update_background()

func update_background(case_id: String = "") -> void:
	if case_id != "":
		var tex = AssetLoader.get_background(case_id)
		if tex:
			image_tex = tex
	if not image_tex:
		image_tex = AssetLoader.get_background("default")
	queue_redraw()

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	if image_tex:
		draw_texture_rect(image_tex, Rect2(0, 0, 3840, 2160), false)
		return

	_draw_procedural()

func _draw_procedural() -> void:
	var w: float = 3840.0
	var h: float = 2160.0

	draw_rect(Rect2(0, 0, w, h), bg_color)

	_draw_tunnel_environment(w, h)
	_draw_ground_plane(w, h)
	_draw_atmosphere(w, h)
	_draw_details(w, h)

func _draw_tunnel_environment(w: float, h: float) -> void:
	var tunnel_top: float = h * 0.15
	var tunnel_bot: float = h * 0.85

	draw_rect(Rect2(0, 0, w, tunnel_top), Color(0.03, 0.03, 0.06))
	draw_rect(Rect2(0, tunnel_bot, w, h - tunnel_bot), Color(0.04, 0.04, 0.07))

	draw_line(Vector2(0, tunnel_top), Vector2(w, tunnel_top), Color(0.1, 0.1, 0.15), 4.0)
	draw_line(Vector2(0, tunnel_bot), Vector2(w, tunnel_bot), Color(0.1, 0.1, 0.15), 4.0)

	var segments: int = 12
	var seg_w: float = w / segments
	for i in range(segments + 1):
		var x: float = i * seg_w
		draw_line(Vector2(x, tunnel_top), Vector2(x, tunnel_top + 60), Color(0.08, 0.08, 0.12), 3.0)
		draw_line(Vector2(x, tunnel_bot), Vector2(x, tunnel_bot - 60), Color(0.08, 0.08, 0.12), 3.0)

	for i in range(segments):
		var x: float = i * seg_w + seg_w * 0.3
		draw_rect(Rect2(x - 2, tunnel_top + 15, 4, 30), Color(0.15, 0.1, 0.05, 0.25 + sin(time * 0.7 + i) * 0.1))

func _draw_ground_plane(w: float, h: float) -> void:
	var ground_y: float = h * 0.88
	var rail_y: float = ground_y + 20

	for i in range(2):
		var rx: float = float(i) * 1900.0 - sin(time * 0.3) * 50.0
		var ry: float = rail_y + i * 25.0
		for j in range(80):
			var sx: float = rx + j * 48.0
			var flicker: float = randf() * 0.3 + 0.7
			draw_rect(Rect2(sx, ry, 42, 2), Color(0.25, 0.25, 0.3, 0.6 * flicker))

	draw_rect(Rect2(0, ground_y + 50, w, 4), Color(0.15, 0.15, 0.2))

	var gravel_count: int = 40
	for i in range(gravel_count):
		var gx: float = fmod(sin(i * 1.7 + time * 0.2) * 1900.0 + 1920.0, w)
		var gy: float = ground_y + 55.0 + randf() * 20.0
		draw_circle(Vector2(gx, gy), randf() * 2.0 + 1.0, Color(0.2, 0.2, 0.25, 0.4))

func _draw_atmosphere(w: float, h: float) -> void:
	for i in range(5):
		var ax: float = fmod(sin(i * 2.3 + time * 0.15) * 2000.0 + 1920.0, w)
		var ay: float = 100.0 + i * 350.0 + cos(time * 0.4 + i) * 80.0
		var alpha: float = 0.02 + sin(time * 0.3 + i) * 0.01
		draw_circle(Vector2(ax, ay), 300.0, Color(0.1, 0.08, 0.2, alpha))

	for i in range(3):
		var lx: float = fmod(cos(i * 1.5 + time * 0.2) * 1800.0 + 1920.0, w)
		var ly: float = 400.0 + i * 500.0
		var flicker: float = 0.3 + sin(time * (3.0 + i) + i * 10.0) * 0.15
		var warm: Color = Color(0.6, 0.35, 0.1, flicker * 0.3)
		draw_circle(Vector2(lx, ly), 18.0, warm)
		draw_circle(Vector2(lx, ly), 60.0, Color(warm.r, warm.g, warm.b, 0.04))

func _draw_details(w: float, h: float) -> void:
	var tunnel_top: float = h * 0.15
	var tunnel_bot: float = h * 0.85

	for i in range(8):
		var px: float = fmod(sin(i * 1.3 + time * 0.1) * 1900.0 + 1920.0, w)
		var py: float = tunnel_top + randf() * (tunnel_bot - tunnel_top)
		var size: float = randf() * 3.0 + 1.0
		draw_circle(Vector2(px, py), size, Color(0.3, 0.3, 0.4, 0.15 + randf() * 0.1))

	var pillar_count: int = 6
	for i in range(pillar_count):
		var px: float = 320.0 + i * (w - 640.0) / (pillar_count - 1)
		var py_base: float = tunnel_bot + 15.0
		var pillar_h: float = 80.0 + sin(i * 1.5) * 20.0
		draw_rect(Rect2(px - 12, py_base - pillar_h, 24, pillar_h), Color(0.06, 0.06, 0.09))
		draw_line(Vector2(px - 15, py_base - pillar_h), Vector2(px + 15, py_base - pillar_h), Color(0.12, 0.12, 0.18), 3.0)
