extends Node2D

const SIZE := Vector2(1280, 720)
const TEAL := Color(0.0, 0.5, 0.5)

func _draw() -> void:
	# Classic Win 95 teal desktop
	draw_rect(Rect2(0, 0, SIZE.x, SIZE.y), TEAL)
	# Subtle dot pattern for texture
	for y in range(0, int(SIZE.y), 16):
		for x in range(0, int(SIZE.x), 16):
			draw_rect(Rect2(x, y, 1, 1), Color(0, 0.55, 0.55, 0.6))
