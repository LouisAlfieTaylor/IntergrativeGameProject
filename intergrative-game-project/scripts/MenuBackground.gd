extends Node2D

const SIZE := Vector2(1280, 720)

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	# Vertical gradient
	for y in range(0, int(SIZE.y), 4):
		var t = y / SIZE.y
		var c = Color(0.10, 0.13, 0.22).lerp(Color(0.18, 0.24, 0.40), t)
		draw_rect(Rect2(0, y, SIZE.x, 4), c)
	# Decorative diagonal lines (subtle)
	for i in range(-10, 30):
		var x = i * 80
		draw_line(Vector2(x, 0), Vector2(x + 240, SIZE.y), Color(1, 1, 1, 0.04), 1.0)
	# Floating circles for depth
	var spots := [
		Vector2(120, 110), Vector2(1100, 90), Vector2(220, 600),
		Vector2(1080, 580), Vector2(640, 60), Vector2(640, 660),
	]
	for s in spots:
		draw_circle(s, 80, Color(0.95, 0.85, 0.40, 0.05))
	# Bottom highlight
	draw_rect(Rect2(0, SIZE.y - 4, SIZE.x, 4), Color(0.95, 0.85, 0.40, 0.5))
