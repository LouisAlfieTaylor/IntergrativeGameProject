extends Control

# Per-level config
const STRESS_MAX := 100.0
const STRESS_RELIEF := 0.6
const TASK_SCENE := preload("res://scenes/Task.tscn")
const MAX_BUDDY_CAMEOS_PER_LEVEL := 2
const BUDDY_CAMEO_CHANCE := 0.18

signal round_ended(won: bool)

@onready var sv: SubViewport = $GameWindow/ViewportContainer/SubViewport
@onready var player: CharacterBody2D = sv.get_node("World/Player")
@onready var hud: CanvasLayer = sv.get_node("HUD")
@onready var tasks_root: Node2D = sv.get_node("World/Tasks")
@onready var spawn_points: Node2D = sv.get_node("World/SpawnPoints")
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

var round_time: float = 60.0
var spawn_min: float = 1.5
var spawn_max: float = 3.4
var max_active_tasks: int = 4
var task_duration_start: float = 8.5
var task_duration_end: float = 5.0

var time_left: float = 0.0
var stress: float = 0.0
var score: int = 0
var tasks_completed: int = 0
var tasks_perfect: int = 0
var round_active: bool = false
var paused: bool = false
var _buddy_cameos_left: int = MAX_BUDDY_CAMEOS_PER_LEVEL

func _ready() -> void:
	randomize()
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_apply_level_config(GameState.current_level)
	time_left = round_time

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
	title_label.text = "Crunch Time - briefcase.exe (Level %d)" % GameState.current_level

	pause_layer.visible = false
	if music.stream is AudioStreamWAV:
		music.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	music.play()
	_start_round()

func _update_clock() -> void:
	var t = Time.get_time_dict_from_system()
	var hour: int = t.hour
	var ampm := "AM" if hour < 12 else "PM"
	hour = hour % 12
	if hour == 0:
		hour = 12
	clock_label.text = "%d:%02d %s" % [hour, t.minute, ampm]

func _on_close() -> void:
	# X button — confirm via Buddy then back to desktop
	Buddy.show_line("Quitting? You'll lose this run!", func(): _quit_to_desktop())

func _on_minimize_or_max() -> void:
	# Min/Max are decorative; nudge the player back to playing
	Buddy.show_line("Heh, those buttons are just for show. Get back in there!")

func _quit_to_desktop() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Desktop.tscn")

func _apply_level_config(level: int) -> void:
	match level:
		1:
			round_time = 60.0
			spawn_min = 1.7
			spawn_max = 3.5
			max_active_tasks = 3
			task_duration_start = 9.0
			task_duration_end = 6.0
		2:
			round_time = 75.0
			spawn_min = 1.4
			spawn_max = 2.8
			max_active_tasks = 4
			task_duration_start = 8.0
			task_duration_end = 5.0
		_:
			round_time = 90.0
			spawn_min = 1.0
			spawn_max = 2.2
			max_active_tasks = 5
			task_duration_start = 7.0
			task_duration_end = 4.0

func _start_round() -> void:
	round_active = true
	_schedule_next_spawn()
	round_timer.start()

func _process(delta: float) -> void:
	if not round_active:
		return
	stress = max(0.0, stress - STRESS_RELIEF * delta)
	hud.set_stress(stress, STRESS_MAX)
	stress_overlay.color.a = lerp(0.0, 0.55, stress / STRESS_MAX)
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
	var progress = 1.0 - time_left / round_time
	t = lerp(t, t * 0.6, progress)
	spawn_timer.wait_time = max(0.5, t)
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
	var amount := 14.0 if reason == "MISS" else 18.0
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

# Pause menu callbacks
func resume() -> void:
	if paused:
		_toggle_pause()

func restart() -> void:
	get_tree().paused = false
	GameState.start_new_run()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func to_main_menu() -> void:
	_quit_to_desktop()
