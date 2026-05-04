extends Node2D

# Visual glitches for the level 3 "corrupted desktop" theme. Drawn over the
# game viewport — periodic color flickers, scanlines, and screen-tear bands.

@export var area: Vector2 = Vector2(1140, 576)
@export var enabled: bool = true

var _next_event: float = 0.0
var _scanline_phase: float = 0.0
var _tear_bands: Array = []  # array of {y, h, dx, ttl}
var _color_flash: float = 0.0  # 0..1
var _flash_color: Color = Color.RED

func _ready() -> void:
	_schedule_next()

func _process(delta: float) -> void:
	if not enabled:
		return
	_scanline_phase += delta * 12.0
	_color_flash = max(0.0, _color_flash - delta * 1.6)
	# Decay tear bands
	var still_live := []
	for b in _tear_bands:
		b["ttl"] -= delta
		if b["ttl"] > 0.0:
			still_live.append(b)
	_tear_bands = still_live
	_next_event -= delta
	if _next_event <= 0.0:
		_trigger_random_event()
		_schedule_next()
	queue_redraw()

func _schedule_next() -> void:
	_next_event = randf_range(1.6, 4.5)

func _trigger_random_event() -> void:
	match randi() % 4:
		0: _color_flash_event()
		1: _tear_event()
		2: _color_flash_event()
		3: _tear_event()

func _color_flash_event() -> void:
	_flash_color = [Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1), Color(1, 0, 1)][randi() % 4]
	_color_flash = randf_range(0.15, 0.35)

func _tear_event() -> void:
	# Spawn 1-3 horizontal tear bands
	var n := randi_range(1, 3)
	for i in n:
		_tear_bands.append({
			"y": randf_range(20, area.y - 40),
			"h": randf_range(6, 22),
			"dx": randf_range(-30, 30) * (1 if randf() > 0.5 else -1),
			"ttl": randf_range(0.10, 0.35),
		})

func _draw() -> void:
	if not enabled:
		return
	# Scanlines (subtle)
	for y in range(0, int(area.y), 3):
		draw_rect(Rect2(0, y, area.x, 1), Color(0, 0, 0, 0.10))
	# Drifting bright scanline
	var sl_y = int((sin(_scanline_phase) * 0.5 + 0.5) * area.y)
	draw_rect(Rect2(0, sl_y, area.x, 2), Color(0.4, 0.9, 0.7, 0.18))
	# Color flash (full overlay)
	if _color_flash > 0.0:
		var c := _flash_color
		c.a = _color_flash * 0.45
		draw_rect(Rect2(0, 0, area.x, area.y), c)
	# Tear bands — draw colored offset slivers to simulate horizontal tearing
	for b in _tear_bands:
		var y: float = b["y"]
		var h: float = b["h"]
		# A dark band suggesting displaced pixels
		draw_rect(Rect2(0, y, area.x, h), Color(0.08, 0.08, 0.08, 0.6))
		# A colored "ghost" sliver offset to one side
		var ghost_color := Color(0.95, 0.10, 0.10, 0.55) if b["dx"] > 0 else Color(0.10, 0.95, 0.95, 0.55)
		draw_rect(Rect2(b["dx"], y + 1, area.x, max(2, h - 2)), ghost_color)
