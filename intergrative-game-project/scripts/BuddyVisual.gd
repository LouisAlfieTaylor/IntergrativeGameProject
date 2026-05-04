extends Node2D

# A friendly 3.5" floppy disk character.
const BODY_COLOR := Color(0.20, 0.22, 0.30)
const BODY_HIGHLIGHT := Color(0.30, 0.34, 0.45)
const SLIDER_COLOR := Color(0.78, 0.78, 0.82)
const SLIDER_DARK := Color(0.55, 0.55, 0.60)
const LABEL_COLOR := Color(0.95, 0.95, 0.85)
const SHADOW_COLOR := Color(0, 0, 0, 0.35)

var blink_t: float = 0.0
var mouth_state: int = 0  # 0 = closed smile, 1 = open

func _process(delta: float) -> void:
	blink_t += delta
	if blink_t > 3.5:
		blink_t = 0.0
		queue_redraw()
	elif blink_t < 0.18 or (blink_t >= 0.13 and blink_t <= 0.18):
		queue_redraw()

func set_mouth_open(open: bool) -> void:
	var new_state = 1 if open else 0
	if new_state != mouth_state:
		mouth_state = new_state
		queue_redraw()

func _draw() -> void:
	# Shadow
	draw_rect(Rect2(-30, 38, 60, 8), SHADOW_COLOR)
	# Body (floppy disk)
	draw_rect(Rect2(-32, -36, 64, 72), BODY_COLOR)
	draw_rect(Rect2(-32, -36, 64, 4), BODY_HIGHLIGHT)
	draw_rect(Rect2(-32, -36, 64, 72), Color(0, 0, 0, 1), false, 2.0)
	# Metal slider on top
	draw_rect(Rect2(-22, -36, 44, 16), SLIDER_COLOR)
	draw_rect(Rect2(-22, -36, 44, 16), SLIDER_DARK, false, 1.0)
	# Slider notch
	draw_rect(Rect2(-12, -32, 4, 12), BODY_COLOR)
	# Label area
	draw_rect(Rect2(-26, 4, 52, 26), LABEL_COLOR)
	draw_rect(Rect2(-26, 4, 52, 26), Color(0.6, 0.6, 0.5, 1), false, 1.0)
	# Eyes (with blink)
	var blink := blink_t < 0.13
	if blink:
		draw_line(Vector2(-12, -10), Vector2(-4, -10), Color.BLACK, 2.0)
		draw_line(Vector2(4, -10), Vector2(12, -10), Color.BLACK, 2.0)
	else:
		draw_circle(Vector2(-8, -10), 4, Color.BLACK)
		draw_circle(Vector2(8, -10), 4, Color.BLACK)
		draw_circle(Vector2(-7, -11), 1.5, Color.WHITE)
		draw_circle(Vector2(9, -11), 1.5, Color.WHITE)
	# Mouth
	if mouth_state == 0:
		# Closed smile
		draw_arc(Vector2(0, 0), 8, deg_to_rad(20), deg_to_rad(160), 16, Color.BLACK, 2.0, true)
	else:
		# Open mouth (talking)
		draw_circle(Vector2(0, 4), 5, Color(0.30, 0.10, 0.10))
		draw_circle(Vector2(0, 4), 5, Color.BLACK, false)
	# Cheeks
	draw_circle(Vector2(-14, 0), 3, Color(1, 0.5, 0.5, 0.5))
	draw_circle(Vector2(14, 0), 3, Color(1, 0.5, 0.5, 0.5))
