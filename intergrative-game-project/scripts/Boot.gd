extends Control

# A short fake-BIOS POST + Crunch95 login boot cutscene that transitions to the
# Desktop. Press any key to skip.

@onready var bios_label: Label = $BIOSLayer/Margin/BIOSText
@onready var loading_layer: Control = $LoadingLayer
@onready var loading_bar: ProgressBar = $LoadingLayer/VBox/Bar
@onready var loading_text: Label = $LoadingLayer/VBox/Status
@onready var login_layer: Control = $LoginLayer
@onready var login_user: LineEdit = $LoginLayer/Window/Content/UserField
@onready var login_pass: LineEdit = $LoginLayer/Window/Content/PassField
@onready var login_ok: Button = $LoginLayer/Window/Content/Buttons/OKBtn
@onready var login_cancel: Button = $LoginLayer/Window/Content/Buttons/CancelBtn
@onready var bios_beep: AudioStreamPlayer = $BIOSBeep
@onready var bios_layer: Control = $BIOSLayer

var _bios_lines: Array[String] = [
	"Award Modular BIOS v4.51PG, An Energy Star Ally",
	"Copyright (C) 1984-95, Award Software, Inc.",
	"",
	"BIOS DATE: 04/30/95",
	"DETECTING IDE PRIMARY MASTER  ... CRUNCH HD-540",
	"DETECTING IDE PRIMARY SLAVE   ... NONE",
	"DETECTING IDE SECONDARY MASTER... NONE",
	"DETECTING IDE SECONDARY SLAVE ... NONE",
	"",
	"INITIALIZING SOUND BLASTER 16 ... OK",
	"VIDEO  : VGA 1024x768 @ 60Hz   OK",
	"MEMORY : 16384KB OK",
	"",
	"Booting from C: ...",
]

var _skipped := false
var _phase := 0  # 0 = bios, 1 = loading, 2 = login, 3 = done

func _ready() -> void:
	loading_layer.visible = false
	login_layer.visible = false
	bios_label.text = ""
	login_user.text = "USER"
	login_pass.text = "********"
	login_ok.pressed.connect(_on_login_ok)
	login_cancel.pressed.connect(_on_login_ok)  # cancel just continues anyway
	_run_sequence()

func _input(event: InputEvent) -> void:
	if event.is_pressed() and not _skipped and _phase < 2:
		_skipped = true

func _run_sequence() -> void:
	_phase = 0
	# BIOS lines, fast typing
	for line in _bios_lines:
		bios_label.text += line + "\n"
		await get_tree().create_timer(0.13 if not _skipped else 0.01, true).timeout
	if not _skipped:
		await get_tree().create_timer(0.25, true).timeout
		bios_beep.play()
		await get_tree().create_timer(0.4, true).timeout

	# Loading screen
	_phase = 1
	bios_layer.visible = false
	loading_layer.visible = true
	loading_text.text = "Loading Crunch95..."
	var steps := [
		[0.15, "Loading kernel..."],
		[0.40, "Initializing GUI shell..."],
		[0.65, "Mounting C:\\WORK"],
		[0.85, "Starting Office Pet daemon..."],
		[1.00, "Welcome!"],
	]
	for s in steps:
		loading_bar.value = float(s[0]) * 100.0
		loading_text.text = s[1]
		await get_tree().create_timer(0.5 if not _skipped else 0.05, true).timeout
	await get_tree().create_timer(0.3, true).timeout

	# Login
	_phase = 2
	loading_layer.visible = false
	login_layer.visible = true
	login_ok.grab_focus()

func _on_login_ok() -> void:
	if _phase >= 3:
		return
	_phase = 3
	# Quick fade-out then change to Desktop
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.3)
	t.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/Desktop.tscn"))
