extends Node2D

const RADIUS := 36.0
const WIDTH := 5.0

var progress: float = 1.0

func set_progress(v: float) -> void:
	progress = clamp(v, 0.0, 1.0)
	queue_redraw()

func _draw() -> void:
	var bg_color := Color(0, 0, 0, 0.25)
	draw_arc(Vector2.ZERO, RADIUS, 0, TAU, 48, bg_color, WIDTH + 2.0, true)
	if progress <= 0.0:
		return
	var color := _color_for_progress(progress)
	var end_angle := -PI / 2 + TAU * progress
	var start_angle := -PI / 2
	draw_arc(Vector2.ZERO, RADIUS, start_angle, end_angle, 64, color, WIDTH, true)

func _color_for_progress(p: float) -> Color:
	if p > 0.5:
		return Color(0.30, 0.85, 0.45).lerp(Color(0.95, 0.85, 0.30), 1.0 - (p - 0.5) * 2.0)
	else:
		return Color(0.95, 0.85, 0.30).lerp(Color(0.95, 0.30, 0.30), 1.0 - p * 2.0)
