extends Node

var won: bool = false
var final_score: int = 0
var tasks_completed: int = 0
var tasks_perfect: int = 0
var time_survived: float = 0.0

func reset() -> void:
	won = false
	final_score = 0
	tasks_completed = 0
	tasks_perfect = 0
	time_survived = 0.0

func record_round(p_won: bool, p_score: int, p_done: int, p_perfect: int, p_time: float) -> void:
	won = p_won
	final_score = p_score
	tasks_completed = p_done
	tasks_perfect = p_perfect
	time_survived = p_time
