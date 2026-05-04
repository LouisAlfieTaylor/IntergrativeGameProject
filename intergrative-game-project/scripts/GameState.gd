extends Node

const SAVE_PATH := "user://gamestate.cfg"
const TOTAL_LEVELS := 3

# Persistent across sessions
var has_seen_tutorial: bool = false

# Per-run state
var won: bool = false
var current_level: int = 1
var run_score: int = 0
var run_tasks_completed: int = 0
var run_tasks_perfect: int = 0
var last_round_won: bool = false
var last_round_score: int = 0
var last_round_tasks_completed: int = 0
var last_round_tasks_perfect: int = 0
var last_round_time_survived: float = 0.0

func _ready() -> void:
	_load()

func start_new_run() -> void:
	won = false
	current_level = 1
	run_score = 0
	run_tasks_completed = 0
	run_tasks_perfect = 0

func record_round(p_won: bool, p_score: int, p_done: int, p_perfect: int, p_time: float) -> void:
	last_round_won = p_won
	last_round_score = p_score
	last_round_tasks_completed = p_done
	last_round_tasks_perfect = p_perfect
	last_round_time_survived = p_time
	if p_won:
		run_score += p_score
		run_tasks_completed += p_done
		run_tasks_perfect += p_perfect
		# Backwards-compat: legacy fields
		won = current_level >= TOTAL_LEVELS
	else:
		won = false

func advance_level() -> bool:
	if current_level >= TOTAL_LEVELS:
		return false
	current_level += 1
	return true

func is_final_level() -> bool:
	return current_level >= TOTAL_LEVELS

# --- backwards-compat shim used by GameOver ---
var final_score: int :
	get:
		return run_score if last_round_won else last_round_score

var tasks_completed: int :
	get:
		return run_tasks_completed if last_round_won else last_round_tasks_completed

# --- persistence ---
func mark_tutorial_seen() -> void:
	has_seen_tutorial = true
	_save()

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("flags", "has_seen_tutorial", has_seen_tutorial)
	cfg.save(SAVE_PATH)

func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	has_seen_tutorial = cfg.get_value("flags", "has_seen_tutorial", false)

func reset() -> void:
	# Used by old Game.gd at scene start
	start_new_run()
