extends Node2D

# The office floor visible inside the game window. Sized to match the
# SubViewport so the player can roam its full extent.

const PALETTES := {
	# Normal — sunny office
	0: {
		"floor": Color(0.78, 0.72, 0.58),
		"floor_dark": Color(0.62, 0.56, 0.42),
		"wall": Color(0.40, 0.46, 0.55),
		"wall_dark": Color(0.30, 0.36, 0.45),
		"desk": Color(0.55, 0.38, 0.22),
		"desk_top": Color(0.72, 0.52, 0.30),
		"monitor": Color(0.20, 0.24, 0.30),
		"screen": Color(0.55, 0.78, 0.92),
		"plant": Color(0.32, 0.62, 0.32),
		"pot": Color(0.55, 0.32, 0.20),
		"rug": Color(0.48, 0.30, 0.42),
		"trim": Color(0.10, 0.13, 0.20),
		"poster_bg": Color(0.95, 0.92, 0.85),
		"poster_line": Color(0.55, 0.55, 0.60),
		"scanline": Color(0.30, 0.55, 0.75, 0.6),
	},
	# Corrupted — dark, red-shifted, virus-feel
	1: {
		"floor": Color(0.18, 0.10, 0.10),
		"floor_dark": Color(0.10, 0.05, 0.05),
		"wall": Color(0.25, 0.10, 0.12),
		"wall_dark": Color(0.45, 0.05, 0.08),
		"desk": Color(0.30, 0.10, 0.10),
		"desk_top": Color(0.40, 0.10, 0.10),
		"monitor": Color(0.05, 0.05, 0.08),
		"screen": Color(0.85, 0.10, 0.10),
		"plant": Color(0.20, 0.30, 0.18),
		"pot": Color(0.20, 0.10, 0.06),
		"rug": Color(0.20, 0.05, 0.10),
		"trim": Color(0.85, 0.30, 0.30),
		"poster_bg": Color(0.20, 0.15, 0.15),
		"poster_line": Color(0.80, 0.30, 0.30),
		"scanline": Color(0.95, 0.30, 0.30, 0.7),
	},
}

@export var area: Vector2 = Vector2(1140, 576)
@export var palette_id: int = 0

const DESK_POSITIONS := [
	Vector2(180, 180), Vector2(570, 180), Vector2(960, 180),
	Vector2(180, 420), Vector2(570, 420), Vector2(960, 420),
]

func set_palette(pid: int) -> void:
	palette_id = pid
	queue_redraw()

func _draw() -> void:
	var p: Dictionary = PALETTES.get(palette_id, PALETTES[0])
	# Wall
	draw_rect(Rect2(0, 0, area.x, 70), p["wall"])
	draw_rect(Rect2(0, 68, area.x, 4), p["wall_dark"])
	# Floor
	draw_rect(Rect2(0, 70, area.x, area.y - 70), p["floor"])
	for x in range(0, int(area.x), 56):
		draw_line(Vector2(x, 70), Vector2(x, area.y), p["floor_dark"], 2.0, false)
	# Rug
	var rug_w = area.x * 0.55
	var rug_h = area.y * 0.32
	draw_rect(Rect2(area.x / 2 - rug_w / 2, area.y * 0.40, rug_w, rug_h), p["rug"])
	# Posters
	for i in range(3):
		var x = area.x * (0.18 + i * 0.30)
		draw_rect(Rect2(x, 12, 88, 48), p["poster_bg"])
		draw_rect(Rect2(x, 12, 88, 48), p["trim"], false, 2.0)
		for line_i in range(3):
			draw_line(Vector2(x + 8, 24 + line_i * 10), Vector2(x + 80, 24 + line_i * 10), p["poster_line"], 1.0)
	# Desks
	for d in DESK_POSITIONS:
		_draw_desk(d, p)
	# Plants
	_draw_plant(Vector2(50, area.y * 0.18), p)
	_draw_plant(Vector2(area.x - 50, area.y * 0.18), p)
	_draw_plant(Vector2(50, area.y - 60), p)
	_draw_plant(Vector2(area.x - 50, area.y - 60), p)

func _draw_desk(center: Vector2, p: Dictionary) -> void:
	draw_rect(Rect2(center.x - 70, center.y - 36, 140, 76), Color(0, 0, 0, 0.25))
	draw_rect(Rect2(center.x - 68, center.y - 38, 136, 70), p["desk_top"])
	draw_rect(Rect2(center.x - 68, center.y - 38, 136, 70), p["trim"], false, 2.0)
	draw_rect(Rect2(center.x - 60, center.y + 24, 8, 12), p["desk"])
	draw_rect(Rect2(center.x + 52, center.y + 24, 8, 12), p["desk"])
	# Monitor
	var mx = center.x - 14
	var my = center.y - 32
	draw_rect(Rect2(mx, my, 32, 22), p["monitor"])
	draw_rect(Rect2(mx + 2, my + 2, 28, 16), p["screen"])
	for sl in range(3):
		draw_line(Vector2(mx + 2, my + 4 + sl * 4), Vector2(mx + 30, my + 4 + sl * 4), p["scanline"], 1.0)
	draw_rect(Rect2(mx + 13, my + 22, 6, 4), p["monitor"])
	# Keyboard
	draw_rect(Rect2(center.x - 24, center.y - 6, 48, 8), Color(0.20, 0.20, 0.24))
	# Coffee mug
	draw_circle(Vector2(center.x + 36, center.y - 12), 5, Color(0.95, 0.95, 0.95))
	draw_circle(Vector2(center.x + 36, center.y - 12), 5, p["trim"], false)

func _draw_plant(center: Vector2, p: Dictionary) -> void:
	draw_rect(Rect2(center.x - 14, center.y, 28, 18), p["pot"])
	draw_rect(Rect2(center.x - 14, center.y, 28, 18), p["trim"], false, 1.0)
	draw_circle(Vector2(center.x, center.y - 8), 14, p["plant"])
	draw_circle(Vector2(center.x - 10, center.y - 4), 10, p["plant"])
	draw_circle(Vector2(center.x + 10, center.y - 4), 10, p["plant"])
	draw_circle(Vector2(center.x - 4, center.y - 18), 9, p["plant"])
	draw_circle(Vector2(center.x + 4, center.y - 16), 9, p["plant"])
