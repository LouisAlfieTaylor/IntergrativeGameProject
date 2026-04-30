extends Node2D

const BG_COLOR := Color(0.98, 0.94, 0.85)
const BG_BORDER := Color(0.18, 0.22, 0.30)
const SHADOW_COLOR := Color(0, 0, 0, 0.25)

var kind: int = 0

func set_kind(k: int) -> void:
	kind = k
	queue_redraw()

func _draw() -> void:
	# Shadow
	draw_circle(Vector2(2, 4), 28, SHADOW_COLOR)
	# BG circle
	draw_circle(Vector2(0, 0), 28, BG_COLOR)
	draw_arc(Vector2(0, 0), 28, 0, TAU, 48, BG_BORDER, 3.0, true)
	match kind:
		0: _draw_email()
		1: _draw_phone()
		2: _draw_coffee()
		3: _draw_deadline()

func _draw_email() -> void:
	var c := Color(0.18, 0.42, 0.78)
	# envelope
	var rect := Rect2(-16, -10, 32, 20)
	draw_rect(rect, c)
	# fold lines
	draw_line(Vector2(-16, -10), Vector2(0, 4), Color.WHITE, 2.0, true)
	draw_line(Vector2(16, -10), Vector2(0, 4), Color.WHITE, 2.0, true)
	# border
	draw_rect(rect, Color(1, 1, 1, 0.85), false, 2.0)

func _draw_phone() -> void:
	var c := Color(0.18, 0.62, 0.32)
	# handset shape (rotated rounded bar)
	var pts := PackedVector2Array([
		Vector2(-16, -2), Vector2(-12, -10), Vector2(-4, -12),
		Vector2(8, -8), Vector2(14, 4), Vector2(10, 10),
		Vector2(2, 6), Vector2(-8, 12), Vector2(-14, 8)
	])
	draw_colored_polygon(pts, c)
	draw_polyline(pts + PackedVector2Array([pts[0]]), Color.WHITE, 1.5, true)

func _draw_coffee() -> void:
	# Cup
	var cup := PackedVector2Array([
		Vector2(-10, -10), Vector2(10, -10), Vector2(8, 12), Vector2(-8, 12)
	])
	draw_colored_polygon(cup, Color(1, 1, 1))
	draw_polyline(cup + PackedVector2Array([cup[0]]), Color(0.18, 0.22, 0.30), 1.5, true)
	# Coffee
	draw_rect(Rect2(-9, -10, 18, 4), Color(0.36, 0.20, 0.10))
	# Steam
	draw_arc(Vector2(-4, -16), 3, PI, 0, 8, Color(0.7, 0.7, 0.7), 1.5, true)
	draw_arc(Vector2(2, -18), 3, PI, 0, 8, Color(0.7, 0.7, 0.7), 1.5, true)
	# Handle
	draw_arc(Vector2(11, 0), 4.5, -PI / 2, PI / 2, 12, Color(0.18, 0.22, 0.30), 2.0, true)

func _draw_deadline() -> void:
	# clock face
	draw_circle(Vector2(0, 0), 14, Color(0.92, 0.32, 0.30))
	draw_arc(Vector2(0, 0), 14, 0, TAU, 32, Color.WHITE, 2.0, true)
	# hands
	draw_line(Vector2(0, 0), Vector2(0, -10), Color.WHITE, 2.5, true)
	draw_line(Vector2(0, 0), Vector2(7, 2), Color.WHITE, 2.0, true)
	# top knob
	draw_rect(Rect2(-2, -16, 4, 4), Color(0.18, 0.22, 0.30))
