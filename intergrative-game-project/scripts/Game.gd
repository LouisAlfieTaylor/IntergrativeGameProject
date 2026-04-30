extends Node2D

const ROUND_TIME := 90.0
const STRESS_MAX := 100.0
const STRESS_RELIEF := 0.6
const TASK_SCENE := preload("res://scenes/Task.tscn")

const SPAWN_MIN := 1.4
const SPAWN_MAX := 3.2
const MAX_ACTIVE_TASKS := 4
const TASK_DURATION_START := 8.0
const TASK_DURATION_END := 4.5

signal round_ended(won: bool)

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var tasks_root: Node2D = $Tasks
@onready var spawn_points: Node2D = $SpawnPoints
@onready var music: AudioStreamPlayer = $Music
@onready var stress_overlay: ColorRect = $UILayer/StressOverlay
@onready var flash_overlay: ColorRect = $UILayer/FlashOverlay
@onready var pause_layer: Control = $UILayer/PauseMenu
@onready var spawn_timer: Timer = $SpawnTimer
@onready var round_timer: Timer = $RoundTimer

var time_left: float = ROUND_TIME
var stress: float = 0.0
var score: int = 0
var tasks_completed: int = 0
var tasks_perfect: int = 0
var round_active: bool = false
var paused: bool = false

func _ready() -> void:
	randomize()
	process_mode = Node.PROCESS_MODE_PAUSABLE
	player.add_to_group("player")
	player.global_position = Vector2(640, 360)
	player.focus_changed.connect(hud.set_focus)
	player.focus_burst_started.connect(hud.show_focus_burst)
	player.focus_burst_ended.connect(hud.hide_focus_burst)
	hud.set_score(score)
	hud.set_stress(stress, STRESS_MAX)
	hud.set_time_left(time_left)

	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_on_spawn_timer)
	round_timer.timeout.connect(_on_round_tick)
	round_timer.wait_time = 1.0

	pause_layer.visible = false
	GameState.reset()
	if music.stream is AudioStreamWAV:
		music.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	music.play()
	_start_round()

func _start_round() -> void:
	round_active = true
	_schedule_next_spawn()
	round_timer.start()

func _process(delta: float) -> void:
	if not round_active:
		return
	# Stress drains slowly between hits to reward staying calm
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
	var t = randf_range(SPAWN_MIN, SPAWN_MAX)
	# Ramp difficulty: spawn faster as time runs out
	var progress = 1.0 - time_left / ROUND_TIME
	t = lerp(t, t * 0.6, progress)
	spawn_timer.wait_time = max(0.6, t)
	spawn_timer.start()

func _on_spawn_timer() -> void:
	if not round_active:
		return
	if tasks_root.get_child_count() < MAX_ACTIVE_TASKS:
		_spawn_task()
	_schedule_next_spawn()

func _spawn_task() -> void:
	var spots := spawn_points.get_children().filter(func(n): return n is Marker2D)
	if spots.is_empty():
		return
	# Pick a spot not already occupied
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
	var progress = 1.0 - time_left / ROUND_TIME
	task.duration = lerp(TASK_DURATION_START, TASK_DURATION_END, progress)
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
	else:
		player.add_focus(6.0)

func _on_task_failed(reason: String) -> void:
	var amount := 14.0 if reason == "MISS" else 18.0
	stress = min(STRESS_MAX, stress + amount)
	hud.set_stress(stress, STRESS_MAX)
	hud.show_popup(tr(reason))
	_flash_red()
	if stress >= STRESS_MAX:
		_end_round(false)

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
	GameState.record_round(won, score, tasks_completed, tasks_perfect, ROUND_TIME - time_left)
	music.stop()
	round_ended.emit(won)
	# Quick fade then transition
	var tween := create_tween()
	tween.tween_property(flash_overlay, "color", Color(0, 0, 0, 1), 0.6)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/GameOver.tscn"))

# Pause menu callbacks
func resume() -> void:
	if paused:
		_toggle_pause()

func restart() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func to_main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
