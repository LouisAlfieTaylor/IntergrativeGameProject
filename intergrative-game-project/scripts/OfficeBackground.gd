extends Node2D

const FLOOR_COLOR := Color(0.78, 0.72, 0.58)
const FLOOR_DARK := Color(0.62, 0.56, 0.42)
const WALL_COLOR := Color(0.40, 0.46, 0.55)
const DESK_COLOR := Color(0.55, 0.38, 0.22)
const DESK_TOP := Color(0.72, 0.52, 0.30)
const MONITOR_COLOR := Color(0.20, 0.24, 0.30)
const MONITOR_SCREEN := Color(0.55, 0.78, 0.92)
const PLANT_GREEN := Color(0.32, 0.62, 0.32)
const PLANT_POT := Color(0.55, 0.32, 0.20)
const RUG_COLOR := Color(0.48, 0.30, 0.42)

@export var area: Vector2 = Vector2(1280, 720)

func _draw() -> void:
	# Wall band along the top
	draw_rect(Rect2(0, 0, area.x, 80), WALL_COLOR)
	# Floor
	draw_rect(Rect2(0, 80, area.x, area.y - 80), FLOOR_COLOR)
	# Floor planks
	for x in range(0, int(area.x), 64):
		draw_line(Vector2(x, 80), Vector2(x, area.y), FLOOR_DARK, 1.5, true)
	# Center rug
	draw_rect(Rect2(area.x * 0.25, area.y * 0.42, area.x * 0.5, area.y * 0.32), RUG_COLOR)
	# Wall posters
	for i in range(3):
		var x = 200 + i * 320
		draw_rect(Rect2(x, 14, 100, 56), Color(0.95, 0.92, 0.85))
		draw_rect(Rect2(x, 14, 100, 56), Color(0.18, 0.22, 0.30), false, 2.0)
	# Desks at the spawn locations
	var desks := [
		Vector2(180, 220), Vector2(640, 200), Vector2(1100, 220),
		Vector2(180, 540), Vector2(640, 560), Vector2(1100, 540),
	]
	for d in desks:
		_draw_desk(d)
	# Plants in corners
	_draw_plant(Vector2(60, 160))
	_draw_plant(Vector2(1220, 160))
	_draw_plant(Vector2(60, 660))
	_draw_plant(Vector2(1220, 660))

func _draw_desk(center: Vector2) -> void:
	# Shadow
	draw_rect(Rect2(center.x - 70, center.y - 38, 140, 80), Color(0, 0, 0, 0.18))
	# Top
	draw_rect(Rect2(center.x - 68, center.y - 40, 136, 76), DESK_TOP)
	draw_rect(Rect2(center.x - 68, center.y - 40, 136, 76), Color(0, 0, 0, 0.4), false, 2.0)
	# Legs
	draw_rect(Rect2(center.x - 60, center.y + 28, 8, 12), DESK_COLOR)
	draw_rect(Rect2(center.x + 52, center.y + 28, 8, 12), DESK_COLOR)
	# Monitor
	var mx = center.x - 12
	var my = center.y - 36
	draw_rect(Rect2(mx, my, 30, 22), MONITOR_COLOR)
	draw_rect(Rect2(mx + 2, my + 2, 26, 16), MONITOR_SCREEN)
	# Stand
	draw_rect(Rect2(mx + 12, my + 22, 6, 4), MONITOR_COLOR)
	# Keyboard
	draw_rect(Rect2(center.x - 24, center.y - 8, 48, 8), Color(0.25, 0.25, 0.30))
	# Coffee mug
	draw_circle(Vector2(center.x + 36, center.y - 14), 5, Color(1, 1, 1))
	draw_circle(Vector2(center.x + 36, center.y - 14), 5, Color(0.18, 0.22, 0.30), false)

func _draw_plant(center: Vector2) -> void:
	# Pot
	draw_rect(Rect2(center.x - 14, center.y, 28, 18), PLANT_POT)
	# Leaves (overlapping circles)
	draw_circle(Vector2(center.x, center.y - 8), 14, PLANT_GREEN)
	draw_circle(Vector2(center.x - 10, center.y - 4), 10, PLANT_GREEN)
	draw_circle(Vector2(center.x + 10, center.y - 4), 10, PLANT_GREEN)
	draw_circle(Vector2(center.x - 4, center.y - 18), 9, PLANT_GREEN)
	draw_circle(Vector2(center.x + 4, center.y - 16), 9, PLANT_GREEN)
