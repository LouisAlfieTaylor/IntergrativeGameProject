extends Node2D

const WIDTH := 160.0
const HEIGHT := 16.0

var perfect_half: float = 0.06
var good_half: float = 0.18
var cursor: float = 0.0

func set_zones(p_half: float, g_half: float) -> void:
	perfect_half = p_half
	good_half = g_half
	queue_redraw()

func set_cursor(c: float) -> void:
	cursor = clamp(c, 0.0, 1.0)
	queue_redraw()

func _draw() -> void:
	var rect := Rect2(-WIDTH / 2, -HEIGHT / 2, WIDTH, HEIGHT)
	# bg
	draw_rect(rect, Color(0.13, 0.15, 0.20))
	# good zone (yellow band)
	var good_rect := Rect2(-good_half * WIDTH, -HEIGHT / 2, good_half * 2 * WIDTH, HEIGHT)
	draw_rect(good_rect, Color(0.95, 0.78, 0.25))
	# perfect zone (green core)
	var perf_rect := Rect2(-perfect_half * WIDTH, -HEIGHT / 2, perfect_half * 2 * WIDTH, HEIGHT)
	draw_rect(perf_rect, Color(0.30, 0.85, 0.40))
	# border
	draw_rect(rect, Color(1, 1, 1, 0.85), false, 1.5)
	# cursor
	var cx = lerp(-WIDTH / 2, WIDTH / 2, cursor)
	draw_rect(Rect2(cx - 2, -HEIGHT / 2 - 4, 4, HEIGHT + 8), Color.WHITE)
