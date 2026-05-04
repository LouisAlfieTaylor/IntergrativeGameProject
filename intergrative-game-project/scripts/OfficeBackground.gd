extends Node2D

# The office floor visible inside the game window. Sized to match the
# SubViewport so the player can roam its full extent.

const FLOOR_COLOR := Color(0.78, 0.72, 0.58)
const FLOOR_DARK := Color(0.62, 0.56, 0.42)
const WALL_COLOR := Color(0.40, 0.46, 0.55)
const WALL_DARK := Color(0.30, 0.36, 0.45)
const DESK_COLOR := Color(0.55, 0.38, 0.22)
const DESK_TOP := Color(0.72, 0.52, 0.30)
const MONITOR_COLOR := Color(0.20, 0.24, 0.30)
const MONITOR_SCREEN := Color(0.55, 0.78, 0.92)
const PLANT_GREEN := Color(0.32, 0.62, 0.32)
const PLANT_POT := Color(0.55, 0.32, 0.20)
const RUG_COLOR := Color(0.48, 0.30, 0.42)

@export var area: Vector2 = Vector2(1140, 576)

# Source of truth for desk positions — used both for drawing AND for spawn
# point setup in Game.tscn. Keep these in sync with the Marker2Ds.
const DESK_POSITIONS := [
	Vector2(180, 180), Vector2(570, 180), Vector2(960, 180),
	Vector2(180, 420), Vector2(570, 420), Vector2(960, 420),
]

func _draw() -> void:
	# Wall band along the top
	draw_rect(Rect2(0, 0, area.x, 70), WALL_COLOR)
	# Beige wall trim line
	draw_rect(Rect2(0, 68, area.x, 4), WALL_DARK)
	# Floor
	draw_rect(Rect2(0, 70, area.x, area.y - 70), FLOOR_COLOR)
	# Floor planks (pixel-y vertical lines)
	for x in range(0, int(area.x), 56):
		draw_line(Vector2(x, 70), Vector2(x, area.y), FLOOR_DARK, 2.0, false)
	# Center rug
	var rug_w = area.x * 0.55
	var rug_h = area.y * 0.32
	draw_rect(Rect2(area.x / 2 - rug_w / 2, area.y * 0.40, rug_w, rug_h), RUG_COLOR)
	# Wall posters
	for i in range(3):
		var x = area.x * (0.18 + i * 0.30)
		draw_rect(Rect2(x, 12, 88, 48), Color(0.95, 0.92, 0.85))
		draw_rect(Rect2(x, 12, 88, 48), Color(0.10, 0.13, 0.20), false, 2.0)
		# Tiny lines on poster
		for line_i in range(3):
			draw_line(Vector2(x + 8, 24 + line_i * 10), Vector2(x + 80, 24 + line_i * 10), Color(0.55, 0.55, 0.60), 1.0)
	# Desks
	for d in DESK_POSITIONS:
		_draw_desk(d)
	# Plants in corners
	_draw_plant(Vector2(50, area.y * 0.18))
	_draw_plant(Vector2(area.x - 50, area.y * 0.18))
	_draw_plant(Vector2(50, area.y - 60))
	_draw_plant(Vector2(area.x - 50, area.y - 60))

func _draw_desk(center: Vector2) -> void:
	# Shadow (chunky pixel feel)
	draw_rect(Rect2(center.x - 70, center.y - 36, 140, 76), Color(0, 0, 0, 0.20))
	# Top
	draw_rect(Rect2(center.x - 68, center.y - 38, 136, 70), DESK_TOP)
	draw_rect(Rect2(center.x - 68, center.y - 38, 136, 70), Color(0.10, 0.13, 0.20, 1), false, 2.0)
	# Legs
	draw_rect(Rect2(center.x - 60, center.y + 24, 8, 12), DESK_COLOR)
	draw_rect(Rect2(center.x + 52, center.y + 24, 8, 12), DESK_COLOR)
	# Monitor
	var mx = center.x - 14
	var my = center.y - 32
	draw_rect(Rect2(mx, my, 32, 22), MONITOR_COLOR)
	draw_rect(Rect2(mx + 2, my + 2, 28, 16), MONITOR_SCREEN)
	# Tiny scanlines on the screen
	for sl in range(3):
		draw_line(Vector2(mx + 2, my + 4 + sl * 4), Vector2(mx + 30, my + 4 + sl * 4), Color(0.30, 0.55, 0.75, 0.6), 1.0)
	# Stand
	draw_rect(Rect2(mx + 13, my + 22, 6, 4), MONITOR_COLOR)
	# Keyboard
	draw_rect(Rect2(center.x - 24, center.y - 6, 48, 8), Color(0.25, 0.25, 0.30))
	# Coffee mug
	draw_circle(Vector2(center.x + 36, center.y - 12), 5, Color(1, 1, 1))
	draw_circle(Vector2(center.x + 36, center.y - 12), 5, Color(0.10, 0.13, 0.20), false)

func _draw_plant(center: Vector2) -> void:
	# Pot
	draw_rect(Rect2(center.x - 14, center.y, 28, 18), PLANT_POT)
	draw_rect(Rect2(center.x - 14, center.y, 28, 18), Color(0.30, 0.18, 0.10), false, 1.0)
	# Leaves (overlapping circles)
	draw_circle(Vector2(center.x, center.y - 8), 14, PLANT_GREEN)
	draw_circle(Vector2(center.x - 10, center.y - 4), 10, PLANT_GREEN)
	draw_circle(Vector2(center.x + 10, center.y - 4), 10, PLANT_GREEN)
	draw_circle(Vector2(center.x - 4, center.y - 18), 9, PLANT_GREEN)
	draw_circle(Vector2(center.x + 4, center.y - 16), 9, PLANT_GREEN)
