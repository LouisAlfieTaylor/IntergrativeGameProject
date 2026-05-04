extends CharacterBody2D

# Base movement
const SPEED := 260.0
const ACCEL := 1800.0
const FRICTION := 1600.0

# Focus mechanic
const FOCUS_MAX := 100.0
const FOCUS_REGEN := 6.0
const FOCUS_BURST_COST := 40.0
const FOCUS_BURST_DURATION := 3.0  # real-world seconds the burst lasts
const FOCUS_BURST_TIME_SCALE := 0.45  # how slow the WORLD becomes
# The player's movement and animation are multiplied by 1/TIME_SCALE so the
# world looks slowed but the player feels normal — Flash style.

signal focus_changed(value: float, max_value: float)
signal focus_burst_started(duration: float)
signal focus_burst_ended

@onready var sprite: Node2D = $Visual
@onready var anim: AnimationPlayer = $AnimationPlayer

var focus: float = FOCUS_MAX
var burst_active: bool = false
var burst_end_real_ms: int = 0
var moving: bool = false
var input_locked: bool = false
var facing: int = 1

func _ready() -> void:
	focus_changed.emit(focus, FOCUS_MAX)

func _physics_process(delta: float) -> void:
	var input_vec := Vector2.ZERO
	if not input_locked:
		input_vec.x = Input.get_axis("move_left", "move_right")
		input_vec.y = Input.get_axis("move_up", "move_down")
		if input_vec.length() > 1.0:
			input_vec = input_vec.normalized()

	# Compensation factor — multiplies our motion so we feel normal vs slowed world
	var compensation := 1.0
	if burst_active and Engine.time_scale > 0.0:
		compensation = 1.0 / Engine.time_scale

	var target := input_vec * SPEED * compensation
	var step_accel := ACCEL * compensation
	var step_friction := FRICTION * compensation

	if input_vec.length() > 0.01:
		velocity = velocity.move_toward(target, step_accel * delta)
		moving = true
		if abs(input_vec.x) > 0.1:
			facing = sign(input_vec.x)
			sprite.scale.x = facing
	else:
		velocity = velocity.move_toward(Vector2.ZERO, step_friction * delta)
		moving = velocity.length() > 4.0

	move_and_slide()
	_update_anim(compensation)
	_update_focus(delta)

	if not input_locked and Input.is_action_just_pressed("focus_burst"):
		_try_start_burst()

	if burst_active and Time.get_ticks_msec() >= burst_end_real_ms:
		_on_burst_timeout()

func _update_anim(compensation: float) -> void:
	if moving:
		if anim.current_animation != "walk":
			anim.play("walk")
	else:
		if anim.current_animation != "idle":
			anim.play("idle")
	# AnimationPlayer is also slowed by Engine.time_scale — compensate so the
	# player's walk/idle plays at normal cadence during a burst.
	anim.speed_scale = compensation

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
	Engine.time_scale = FOCUS_BURST_TIME_SCALE
	burst_end_real_ms = Time.get_ticks_msec() + int(FOCUS_BURST_DURATION * 1000.0)
	focus_burst_started.emit(FOCUS_BURST_DURATION)

func _on_burst_timeout() -> void:
	if not burst_active:
		return
	burst_active = false
	Engine.time_scale = 1.0
	anim.speed_scale = 1.0
	focus_burst_ended.emit()

func force_end_burst() -> void:
	if burst_active:
		_on_burst_timeout()
