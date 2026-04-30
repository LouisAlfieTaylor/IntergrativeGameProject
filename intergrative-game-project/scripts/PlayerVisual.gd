extends Node2D

const BODY_COLOR := Color(0.32, 0.55, 0.85)
const SHIRT_COLOR := Color(0.95, 0.95, 0.97)
const TIE_COLOR := Color(0.85, 0.18, 0.22)
const HEAD_COLOR := Color(0.97, 0.84, 0.7)
const HAIR_COLOR := Color(0.25, 0.18, 0.12)

func _draw() -> void:
	# Body (rounded rectangle approx using a polygon)
	var body_pts := PackedVector2Array([
		Vector2(-14, -8), Vector2(14, -8),
		Vector2(18, 4), Vector2(16, 22), Vector2(-16, 22), Vector2(-18, 4),
	])
	draw_colored_polygon(body_pts, BODY_COLOR)
	# Shirt collar
	var collar := PackedVector2Array([
		Vector2(-9, -8), Vector2(9, -8), Vector2(7, 4), Vector2(-7, 4)
	])
	draw_colored_polygon(collar, SHIRT_COLOR)
	# Tie
	var tie := PackedVector2Array([
		Vector2(-3, -6), Vector2(3, -6), Vector2(2, 4), Vector2(4, 18), Vector2(-4, 18), Vector2(-2, 4)
	])
	draw_colored_polygon(tie, TIE_COLOR)
	# Head
	draw_circle(Vector2(0, -18), 11, HEAD_COLOR)
	# Hair
	var hair := PackedVector2Array([
		Vector2(-11, -22), Vector2(-9, -28), Vector2(0, -30), Vector2(9, -28), Vector2(11, -22), Vector2(8, -19), Vector2(-8, -19)
	])
	draw_colored_polygon(hair, HAIR_COLOR)
	# Eyes (small dots)
	draw_circle(Vector2(-3.5, -18), 1.2, Color(0.1, 0.1, 0.15))
	draw_circle(Vector2(3.5, -18), 1.2, Color(0.1, 0.1, 0.15))
	# Shadow under feet
	_draw_oval(Vector2(0, 24), 14, 4, Color(0, 0, 0, 0.25))

func _draw_oval(center: Vector2, rx: float, ry: float, color: Color) -> void:
	var pts := PackedVector2Array()
	var n := 24
	for i in range(n):
		var a := TAU * i / n
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, color)
