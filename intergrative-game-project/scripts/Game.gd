extends Control

# === Difficulty constants (rebalanced — much more forgiving) ===
const STRESS_MAX := 100.0
const STRESS_RELIEF := 1.4              # was 0.6 — recovers more than 1 stress/sec
const STRESS_MISS := 8.0                # was 14 — a miss is now ~6s of regen
const STRESS_EXPIRED := 11.0            # was 18
const TASK_SCENE := preload("res://scenes/Task.tscn")
const POPUP_SCENE := preload("res://scenes/Popup.tscn")
const GLITCH_SCRIPT := preload("res://scripts/GlitchEffect.gd")
const MAX_BUDDY_CAMEOS_PER_LEVEL := 2
const BUDDY_CAMEO_CHANCE := 0.18

signal round_ended(won: bool)

@onready var sv: SubViewport = $GameWindow/ViewportContainer/SubViewport
@onready var player: CharacterBody2D = sv.get_node("World/Player")
@onready var hud: CanvasLayer = sv.get_node("HUD")
@onready var tasks_root: Node2D = sv.get_node("World/Tasks")
@onready var spawn_points: Node2D = sv.get_node("World/SpawnPoints")
@onready var office_bg: Node2D = sv.get_node("World/OfficeBg")
@onready var stress_overlay: ColorRect = sv.get_node("OverlayLayer/StressOverlay")
@onready var flash_overlay: ColorRect = sv.get_node("OverlayLayer/FlashOverlay")
@onready var music: AudioStreamPlayer = $Music
@onready var pause_layer: Control = $PauseMenuLayer/PauseMenu
@onready var spawn_timer: Timer = $SpawnTimer
@onready var round_timer: Timer = $RoundTimer
@onready var clock_label: Label = $Taskbar/HBox/ClockPanel/Clock
@onready var clock_timer: Timer = $ClockTimer
@onready var close_btn: Button = $GameWindow/TitleBar/HBox/CloseBtn
@onready var min_btn: Button = $GameWindow/TitleBar/HBox/MinBtn
@onready var max_btn: Button = $GameWindow/TitleBar/HBox/MaxBtn
@onready var title_label: Label = $GameWindow/TitleBar/HBox/Title
@onready var task_layer: CanvasLayer = sv.get_node("PopupLayer")

# Per-level config — set by _apply_level_config
var round_time: float = 60.0
var spawn_min: float = 1.7
var spawn_max: float = 3.5
var max_active_tasks: int = 3
var task_duration_start: float = 9.0
var task_duration_end: float = 6.0
var palette_id: int = 0
var has_popups: bool = false
var has_glitches: bool = false
var popup_min: float = 7.0
var popup_max: float = 11.0
var max_active_popups: int = 2
var window_title: String = "Crunch Time - briefcase.exe"

var time_left: float = 0.0
var stress: float = 0.0
var score: int = 0
var tasks_completed: int = 0
var tasks_perfect: int = 0
var round_active: bool = false
var paused: bool = false
var _buddy_cameos_left: int = MAX_BUDDY_CAMEOS_PER_LEVEL
var _glitch_node: Node2D = null
var _popup_timer: Timer = null

func _ready() -> void:
	randomize()
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_apply_level_config(GameState.current_level)
	time_left = round_time

	# Apply visual theme to office and ambient
	if office_bg.has_method("set_palette"):
		office_bg.set_palette(palette_id)
	var ambient: CanvasModulate = sv.get_node("World/AmbientLight")
	if palette_id == 1:
		ambient.color = Color(0.55, 0.45, 0.55, 1)  # eerie tint
	else:
		ambient.color = Color(0.85, 0.86, 0.92, 1)

	player.add_to_group("player")
	player.focus_changed.connect(hud.set_focus)
	player.focus_burst_started.connect(hud.show_focus_burst)
	player.focus_burst_ended.connect(hud.hide_focus_burst)
	hud.set_score(score)
	hud.set_stress(stress, STRESS_MAX)
	hud.set_time_left(time_left)
	hud.set_level(GameState.current_level, GameState.TOTAL_LEVELS)

	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_on_spawn_timer)
	round_timer.timeout.connect(_on_round_tick)
	round_timer.wait_time = 1.0

	clock_timer.timeout.connect(_update_clock)
	_update_clock()

	close_btn.pressed.connect(_on_close)
	min_btn.pressed.connect(_on_minimize_or_max)
	max_btn.pressed.connect(_on_minimize_or_max)
	title_label.text = window_title

	pause_layer.visible = false
	if music.stream is AudioStreamWAV:
		music.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	music.play()
	_start_round()
	# Modifiers must be set up AFTER _start_round so round_active is true
	# when the popup timer schedules its first tick.
	_setup_level_modifiers()

func _apply_level_config(level: int) -> void:
	# Difficulty progression intentionally gentle. Level 3 is meant to feel
	# challenging but beatable on a focused run.
	match level:
		1:
			round_time = 50.0
			spawn_min = 2.4
			spawn_max = 4.0
			max_active_tasks = 2
			task_duration_start = 10.0
			task_duration_end = 8.5
			palette_id = 0
			has_popups = false
			has_glitches = false
			window_title = "Crunch Time - briefcase.exe (Onboarding)"
		2:
			round_time = 70.0
			spawn_min = 1.9
			spawn_max = 3.4
			max_active_tasks = 3
			task_duration_start = 9.0
			task_duration_end = 7.0
			palette_id = 0
			has_popups = true
			has_glitches = false
			popup_min = 7.0
			popup_max = 11.0
			max_active_popups = 2
			window_title = "Crunch Time - briefcase.exe (Popup Hell)"
		_:
			# Level 3 (and any later)
			round_time = 80.0
			spawn_min = 1.7
			spawn_max = 3.0
			max_active_tasks = 3
			task_duration_start = 8.5
			task_duration_end = 6.5
			palette_id = 1
			has_popups = false
			has_glitches = true
			window_title = "Crunch Time - briefcase.exe (CORRUPTED)"

func _setup_level_modifiers() -> void:
	if has_glitches:
		_glitch_node = Node2D.new()
		_glitch_node.set_script(GLITCH_SCRIPT)
		_glitch_node.set("area", Vector2(1140, 576))
		var overlay_layer = sv.get_node("OverlayLayer")
		overlay_layer.add_child(_glitch_node)

	if has_popups:
		_popup_timer = Timer.new()
		_popup_timer.one_shot = true
		_popup_timer.timeout.connect(_on_popup_timer)
		add_child(_popup_timer)
		# First popup arrives fast so the player notices the level twist
		_popup_timer.wait_time = randf_range(3.0, 5.0)
		_popup_timer.start()

func _schedule_next_popup() -> void:
	if not has_popups or not round_active:
		return
	if _popup_timer:
		_popup_timer.wait_time = randf_range(popup_min, popup_max)
		_popup_timer.start()

func _on_popup_timer() -> void:
	if not round_active:
		return
	if task_layer.get_child_count() < max_active_popups:
		_spawn_popup()
	_schedule_next_popup()

func _spawn_popup() -> void:
	var popup := POPUP_SCENE.instantiate()
	# Stay clear of HUD top bar (~y<88) and bottom bar (~y>508)
	var px = randf_range(60, 860)
	var py = randf_range(100, 350)
	popup.position = Vector2(px, py)
	task_layer.add_child(popup)

func _update_clock() -> void:
	var t = Time.get_time_dict_from_system()
	var hour: int = t.hour
	var ampm := "AM" if hour < 12 else "PM"
	hour = hour % 12
	if hour == 0:
		hour = 12
	clock_label.text = "%d:%02d %s" % [hour, t.minute, ampm]

func _on_close() -> void:
	Buddy.show_line(tr("BUDDY_QUIT_GAME"), func(): _quit_to_desktop())

func _on_minimize_or_max() -> void:
	Buddy.show_line(tr("BUDDY_WINDOW_BTN"))

func _quit_to_desktop() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Desktop.tscn")

func _start_round() -> void:
	round_active = true
	_schedule_next_spawn()
	round_timer.start()

func _process(delta: float) -> void:
	if not round_active:
		return
	stress = max(0.0, stress - STRESS_RELIEF * delta)
	hud.set_stress(stress, STRESS_MAX)
	stress_overlay.color.a = lerp(0.0, 0.45, stress / STRESS_MAX)
	if Input.is_action_just_pressed("pause"):
		_toggle_pause()

func _toggle_pause() -> void:
	paused = not paused
	get_tree().paused = paused
	pause_layer.visible = paused

func _on_round_tick() -> void:
	if not round_active or paused:
		return
	time_left = max(0.0, time_left - 1.0)
	hud.set_time_left(time_left)
	if time_left <= 0.0:
		_end_round(true)

func _schedule_next_spawn() -> void:
	if not round_active:
		return
	var t = randf_range(spawn_min, spawn_max)
	# Mild ramp — late game spawns ~30% faster, not 40%
	var progress = 1.0 - time_left / round_time
	t = lerp(t, t * 0.7, progress)
	spawn_timer.wait_time = max(0.6, t)
	spawn_timer.start()

func _on_spawn_timer() -> void:
	if not round_active:
		return
	if tasks_root.get_child_count() < max_active_tasks:
		_spawn_task()
	_schedule_next_spawn()

func _spawn_task() -> void:
	var spots := spawn_points.get_children().filter(func(n): return n is Marker2D)
	if spots.is_empty():
		return
	var occupied := []
	for t in tasks_root.get_children():
		occupied.append(t.global_position)
	var free_spots := []
	for s in spots:
		var ok := true
		for o in occupied:
			if (s.global_position - o).length() < 30.0:
				ok = false
				break
		if ok:
			free_spots.append(s)
	if free_spots.is_empty():
		return
	var spot = free_spots[randi() % free_spots.size()]
	var task = TASK_SCENE.instantiate()
	task.global_position = spot.global_position
	task.kind = randi() % 4
	var progress = 1.0 - time_left / round_time
	task.duration = lerp(task_duration_start, task_duration_end, progress)
	task.completed.connect(_on_task_completed)
	task.failed.connect(_on_task_failed)
	tasks_root.add_child(task)

func _on_task_completed(p_score: int, result: String) -> void:
	score += p_score
	tasks_completed += 1
	hud.set_score(score)
	hud.show_popup(tr(result))
	if result == "PERFECT":
		tasks_perfect += 1
		player.add_focus(20.0)
		_maybe_buddy_cameo(BuddyDialog.REACT_PERFECT)
	else:
		player.add_focus(6.0)

func _on_task_failed(reason: String) -> void:
	var amount := STRESS_MISS if reason == "MISS" else STRESS_EXPIRED
	stress = min(STRESS_MAX, stress + amount)
	hud.set_stress(stress, STRESS_MAX)
	hud.show_popup(tr(reason))
	_flash_red()
	_maybe_buddy_cameo(BuddyDialog.REACT_MISS)
	if stress >= STRESS_MAX:
		_end_round(false)

func _maybe_buddy_cameo(pool: Array) -> void:
	if _buddy_cameos_left <= 0:
		return
	if randf() > BUDDY_CAMEO_CHANCE:
		return
	_buddy_cameos_left -= 1
	Buddy.show_from_pool(pool)

func _flash_red() -> void:
	flash_overlay.color = Color(1, 0.2, 0.2, 0.45)
	var tween := create_tween()
	tween.tween_property(flash_overlay, "color:a", 0.0, 0.4)

func _end_round(survived: bool) -> void:
	if not round_active:
		return
	var won := survived and stress < STRESS_MAX
	round_active = false
	round_timer.stop()
	spawn_timer.stop()
	if _popup_timer:
		_popup_timer.stop()
	if _glitch_node:
		_glitch_node.set("enabled", false)
	player.force_end_burst()
	player.input_locked = true
	GameState.record_round(won, score, tasks_completed, tasks_perfect, round_time - time_left)
	music.stop()
	round_ended.emit(won)
	var tween := create_tween()
	tween.tween_property(flash_overlay, "color", Color(0, 0, 0, 1), 0.6)
	tween.tween_callback(func(): _go_to_next_scene(won))

func _go_to_next_scene(won: bool) -> void:
	if not won:
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
		return
	if GameState.is_final_level():
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
		return
	GameState.advance_level()
	get_tree().change_scene_to_file("res://scenes/LevelTransition.tscn")

func resume() -> void:
	if paused:
		_toggle_pause()

func restart() -> void:
	get_tree().paused = false
	GameState.start_new_run()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func to_main_menu() -> void:
	_quit_to_desktop()
