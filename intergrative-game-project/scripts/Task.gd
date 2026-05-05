extends Area2D

enum State { WAITING, READY, TIMING, COMPLETE, FAILED }
enum Kind { EMAIL, PHONE, COFFEE, DEADLINE }

const DEFAULT_DURATION := 7.0
const TIMING_DURATION := 1.6
const PERFECT_HALF_WIDTH := 0.06
const GOOD_HALF_WIDTH := 0.18

const SCORE_PERFECT := 150
const SCORE_GOOD := 80
const STRESS_MISS := 14.0
const STRESS_EXPIRED := 18.0
const FOCUS_PERFECT_BONUS := 18.0
const FOCUS_GOOD_BONUS := 6.0

signal completed(score: int, result: String)
signal failed(reason: String)

@export var kind: Kind = Kind.EMAIL
@export var duration: float = DEFAULT_DURATION

@onready var icon: Node2D = $Icon
@onready var ring: Node2D = $TimerRing
@onready var bar: Node2D = $TimingBar
@onready var prompt_label: Label = $Prompt
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var burst: GPUParticles2D = $SuccessBurst
@onready var success_sfx: AudioStreamPlayer = $SuccessSFX
@onready var fail_sfx: AudioStreamPlayer = $FailSFX

var state: int = State.WAITING
var time_left: float = DEFAULT_DURATION
var player_in_range: bool = false
var timing_t: float = 0.0
var timing_dir: int = 1
var _destroyed: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	time_left = duration
	prompt_label.text = tr("PRESS_SPACE")
	prompt_label.visible = false
	bar.visible = false
	icon.set_kind(kind)
	ring.set_progress(1.0)
	if anim.has_animation("appear"):
		anim.play("appear")

func _process(delta: float) -> void:
	if _destroyed:
		return
	match state:
		State.WAITING, State.READY:
			time_left -= delta
			ring.set_progress(time_left / duration)
			if time_left <= 0.0:
				_expire()
				return
			if state == State.READY and Input.is_action_just_pressed("action"):
				_start_timing()
		State.TIMING:
			time_left -= delta
			ring.set_progress(time_left / duration)
			timing_t += delta * timing_dir / TIMING_DURATION * 2.0
			if timing_t >= 1.0:
				timing_t = 1.0
				timing_dir = -1
			elif timing_t <= 0.0:
				timing_t = 0.0
				timing_dir = 1
			bar.set_cursor(timing_t)
			if Input.is_action_just_pressed("action"):
				_resolve_timing()
			elif time_left <= 0.0:
				_expire()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and state == State.WAITING:
		player_in_range = true
		state = State.READY
		prompt_label.visible = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if state == State.READY:
			state = State.WAITING
			prompt_label.visible = false

func _start_timing() -> void:
	state = State.TIMING
	prompt_label.visible = false
	bar.visible = true
	bar.set_zones(PERFECT_HALF_WIDTH, GOOD_HALF_WIDTH)
	timing_t = 0.0
	timing_dir = 1

func _resolve_timing() -> void:
	var dist = abs(timing_t - 0.5)
	var result := ""
	var score := 0
	if dist <= PERFECT_HALF_WIDTH:
		result = "PERFECT"
		score = SCORE_PERFECT
	elif dist <= GOOD_HALF_WIDTH:
		result = "GOOD"
		score = SCORE_GOOD
	else:
		_miss()
		return
	state = State.COMPLETE
	bar.visible = false
	burst.emitting = true
	success_sfx.play()
	if anim.has_animation("complete"):
		anim.play("complete")
	completed.emit(score, result)
	_schedule_destroy(0.55)

func _miss() -> void:
	state = State.FAILED
	bar.visible = false
	fail_sfx.play()
	if anim.has_animation("fail"):
		anim.play("fail")
	failed.emit("MISS")
	_schedule_destroy(0.45)

func _expire() -> void:
	if state in [State.COMPLETE, State.FAILED]:
		return
	state = State.FAILED
	bar.visible = false
	prompt_label.visible = false
	fail_sfx.play()
	if anim.has_animation("fail"):
		anim.play("fail")
	failed.emit("EXPIRED")
	_schedule_destroy(0.45)

func _schedule_destroy(delay: float) -> void:
	_destroyed = true
	monitoring = false
	monitorable = false
	var t := get_tree().create_timer(delay)
	t.timeout.connect(queue_free)
