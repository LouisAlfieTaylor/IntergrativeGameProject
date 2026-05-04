extends Button

# An app icon on the desktop. Draws a simple pixel-art icon plus a label below.
# Uses Button as the root so click handling is built-in.

@export var icon_kind: String = "briefcase"
@export var icon_label: String = "App"

func _ready() -> void:
	custom_minimum_size = Vector2(86, 86)
	flat = true
	text = ""
	# We'll draw the icon ourselves
	queue_redraw()

func _draw() -> void:
	var center := Vector2(size.x / 2, 30)
	match icon_kind:
		"briefcase": _draw_briefcase(center)
		"computer": _draw_computer(center)
		"recycle": _draw_recycle(center)
		"browser": _draw_browser(center)
		"notepad": _draw_notepad(center)
		"settings": _draw_gear(center)
		"tutorial": _draw_book(center)
		"quit": _draw_door(center)
	# Label
	var font := get_theme_default_font()
	var font_size := 14
	var text_size := font.get_string_size(icon_label, HORIZONTAL_ALIGNMENT_CENTER, -1.0, font_size)
	var label_pos := Vector2(size.x / 2 - text_size.x / 2, size.y - 16)
	# Black outline for readability
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx != 0 or dy != 0:
				draw_string(font, label_pos + Vector2(dx, dy), icon_label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.BLACK)
	draw_string(font, label_pos, icon_label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)

func _draw_briefcase(c: Vector2) -> void:
	# Brown briefcase
	draw_rect(Rect2(c.x - 22, c.y - 14, 44, 28), Color(0.55, 0.32, 0.18))
	draw_rect(Rect2(c.x - 22, c.y - 14, 44, 28), Color.BLACK, false, 1.0)
	# Handle
	draw_rect(Rect2(c.x - 8, c.y - 22, 16, 8), Color(0.40, 0.22, 0.12))
	draw_rect(Rect2(c.x - 8, c.y - 22, 16, 8), Color.BLACK, false, 1.0)
	# Latch
	draw_rect(Rect2(c.x - 4, c.y - 4, 8, 4), Color(0.85, 0.75, 0.30))
	# Yellow shine - "important!"
	draw_rect(Rect2(c.x - 22, c.y + 8, 44, 2), Color(0.95, 0.85, 0.30))

func _draw_computer(c: Vector2) -> void:
	# Beige CRT monitor
	draw_rect(Rect2(c.x - 18, c.y - 14, 36, 24), Color(0.85, 0.82, 0.72))
	draw_rect(Rect2(c.x - 18, c.y - 14, 36, 24), Color.BLACK, false, 1.0)
	# Screen
	draw_rect(Rect2(c.x - 14, c.y - 10, 28, 18), Color(0.0, 0.30, 0.50))
	# Stand
	draw_rect(Rect2(c.x - 6, c.y + 10, 12, 4), Color(0.85, 0.82, 0.72))
	draw_rect(Rect2(c.x - 12, c.y + 14, 24, 2), Color(0.85, 0.82, 0.72))

func _draw_recycle(c: Vector2) -> void:
	# Trash can
	var pts := PackedVector2Array([
		Vector2(c.x - 14, c.y - 10), Vector2(c.x + 14, c.y - 10),
		Vector2(c.x + 11, c.y + 14), Vector2(c.x - 11, c.y + 14)
	])
	draw_colored_polygon(pts, Color(0.78, 0.78, 0.82))
	draw_polyline(pts + PackedVector2Array([pts[0]]), Color.BLACK, 1.5, true)
	# Lid
	draw_rect(Rect2(c.x - 16, c.y - 14, 32, 4), Color(0.65, 0.65, 0.70))
	draw_rect(Rect2(c.x - 16, c.y - 14, 32, 4), Color.BLACK, false, 1.0)
	# Recycle arrows (simple)
	draw_arc(c + Vector2(0, 2), 6, 0, TAU * 0.7, 12, Color(0.20, 0.65, 0.30), 2.0, true)

func _draw_browser(c: Vector2) -> void:
	# Globe
	draw_circle(c, 14, Color(0.35, 0.55, 0.85))
	draw_arc(c, 14, 0, TAU, 32, Color(0.10, 0.20, 0.45), 2.0, true)
	# Latitude lines
	draw_arc(c, 14, deg_to_rad(0), deg_to_rad(180), 16, Color(0.10, 0.20, 0.45), 1.0, true)
	draw_line(c + Vector2(-14, 0), c + Vector2(14, 0), Color(0.10, 0.20, 0.45), 1.0)
	draw_line(c + Vector2(0, -14), c + Vector2(0, 14), Color(0.10, 0.20, 0.45), 1.0)

func _draw_notepad(c: Vector2) -> void:
	# White paper
	draw_rect(Rect2(c.x - 12, c.y - 14, 24, 28), Color.WHITE)
	draw_rect(Rect2(c.x - 12, c.y - 14, 24, 28), Color.BLACK, false, 1.0)
	# Lines
	for i in range(4):
		draw_line(c + Vector2(-9, -8 + i * 6), c + Vector2(9, -8 + i * 6), Color(0.35, 0.35, 0.45), 1.0)

func _draw_gear(c: Vector2) -> void:
	# Gear icon (simple)
	var teeth := 8
	for i in range(teeth):
		var a := TAU * i / teeth
		var p1 := c + Vector2(cos(a) * 14, sin(a) * 14)
		draw_rect(Rect2(p1.x - 2, p1.y - 2, 4, 4), Color(0.55, 0.55, 0.62))
	draw_circle(c, 11, Color(0.78, 0.78, 0.82))
	draw_circle(c, 11, Color.BLACK, false)
	draw_circle(c, 4, Color(0.30, 0.30, 0.35))

func _draw_book(c: Vector2) -> void:
	# Open book
	draw_rect(Rect2(c.x - 16, c.y - 10, 32, 22), Color(0.92, 0.88, 0.75))
	draw_rect(Rect2(c.x - 16, c.y - 10, 32, 22), Color.BLACK, false, 1.0)
	draw_line(c + Vector2(0, -10), c + Vector2(0, 12), Color.BLACK, 1.5)
	# Lines
	for i in range(3):
		draw_line(c + Vector2(-13, -5 + i * 5), c + Vector2(-3, -5 + i * 5), Color(0.4, 0.3, 0.2), 1.0)
		draw_line(c + Vector2(3, -5 + i * 5), c + Vector2(13, -5 + i * 5), Color(0.4, 0.3, 0.2), 1.0)

func _draw_door(c: Vector2) -> void:
	# Exit door icon
	draw_rect(Rect2(c.x - 12, c.y - 14, 24, 28), Color(0.55, 0.32, 0.18))
	draw_rect(Rect2(c.x - 12, c.y - 14, 24, 28), Color.BLACK, false, 1.0)
	# Knob
	draw_circle(Vector2(c.x + 6, c.y), 1.5, Color.BLACK)
	# Arrow pointing out
	draw_line(c + Vector2(-8, 0), c + Vector2(2, 0), Color(0.30, 0.85, 0.40), 2.0)
	draw_line(c + Vector2(2, 0), c + Vector2(-2, -3), Color(0.30, 0.85, 0.40), 2.0)
	draw_line(c + Vector2(2, 0), c + Vector2(-2, 3), Color(0.30, 0.85, 0.40), 2.0)
