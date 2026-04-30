extends CharacterBody2D

const SPEED := 260.0
const ACCEL := 1800.0
const FRICTION := 1600.0

const FOCUS_MAX := 100.0
const FOCUS_REGEN := 6.0
const FOCUS_BURST_COST := 40.0
const FOCUS_BURST_DURATION := 3.0
const FOCUS_BURST_SCALE := 0.45

signal focus_changed(value: float, max_value: float)
signal focus_burst_started(duration: float)
signal focus_burst_ended

@onready var sprite: Node2D = $Visual
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var burst_timer: Timer = $FocusBurstTimer

var focus: float = FOCUS_MAX
var burst_active: bool = false
var moving: bool = false
var input_locked: bool = false
var facing: int = 1

func _ready() -> void:
	burst_timer.wait_time = FOCUS_BURST_DURATION
	burst_timer.one_shot = true
	burst_timer.timeout.connect(_on_burst_timeout)
	focus_changed.emit(focus, FOCUS_MAX)

func _physics_process(delta: float) -> void:
	var input_vec := Vector2.ZERO
	if not input_locked:
		input_vec.x = Input.get_axis("move_left", "move_right")
		input_vec.y = Input.get_axis("move_up", "move_down")
		if input_vec.length() > 1.0:
			input_vec = input_vec.normalized()

	var target := input_vec * SPEED
	if input_vec.length() > 0.01:
		velocity = velocity.move_toward(target, ACCEL * delta)
		moving = true
		if abs(input_vec.x) > 0.1:
			facing = sign(input_vec.x)
			sprite.scale.x = facing
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		moving = velocity.length() > 4.0

	move_and_slide()
	_update_anim()
	_update_focus(delta)

	if not input_locked and Input.is_action_just_pressed("focus_burst"):
		_try_start_burst()

func _update_anim() -> void:
	if moving:
		if anim.current_animation != "walk":
			anim.play("walk")
	else:
		if anim.current_animation != "idle":
			anim.play("idle")

func _update_focus(delta: float) -> void:
	if not burst_active:
		focus = min(FOCUS_MAX, focus + FOCUS_REGEN * delta)
		focus_changed.emit(focus, FOCUS_MAX)

func add_focus(amount: float) -> void:
	focus = clamp(focus + amount, 0.0, FOCUS_MAX)
	focus_changed.emit(focus, FOCUS_MAX)

func _try_start_burst() -> void:
	if burst_active or focus < FOCUS_BURST_COST:
		return
	focus -= FOCUS_BURST_COST
	focus_changed.emit(focus, FOCUS_MAX)
	burst_active = true
	Engine.time_scale = FOCUS_BURST_SCALE
	burst_timer.start()
	focus_burst_started.emit(FOCUS_BURST_DURATION)

func _on_burst_timeout() -> void:
	burst_active = false
	Engine.time_scale = 1.0
	focus_burst_ended.emit()

func force_end_burst() -> void:
	if burst_active:
		burst_timer.stop()
		_on_burst_timeout()
