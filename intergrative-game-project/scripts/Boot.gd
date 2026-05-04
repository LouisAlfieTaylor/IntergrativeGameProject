extends Control

# A short fake-BIOS POST + Crunch95 login boot cutscene that transitions to the
# Desktop. Press any key to skip.

@onready var bios_label: Label = $BIOSLayer/Margin/BIOSText
@onready var loading_layer: Control = $LoadingLayer
@onready var loading_bar: ProgressBar = $LoadingLayer/VBox/Bar
@onready var loading_text: Label = $LoadingLayer/VBox/Status
@onready var login_layer: Control = $LoginLayer
@onready var login_title: Label = $LoginLayer/Window/TitleBar/TitleLabel
@onready var login_hint: Label = $LoginLayer/Window/Content/Hint
@onready var login_user_label: Label = $LoginLayer/Window/Content/UserLabel
@onready var login_pass_label: Label = $LoginLayer/Window/Content/PassLabel
@onready var login_user: LineEdit = $LoginLayer/Window/Content/UserField
@onready var login_pass: LineEdit = $LoginLayer/Window/Content/PassField
@onready var login_ok: Button = $LoginLayer/Window/Content/Buttons/OKBtn
@onready var login_cancel: Button = $LoginLayer/Window/Content/Buttons/CancelBtn
@onready var bios_beep: AudioStreamPlayer = $BIOSBeep
@onready var bios_layer: Control = $BIOSLayer

# BIOS POST text is canonically English on real period hardware, so it stays
# untranslated. Player-facing dialog uses tr().
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
	_refresh_login_text()
	LanguageManager.language_changed.connect(func(_l): _refresh_login_text())
	_run_sequence()

func _refresh_login_text() -> void:
	login_title.text = tr("BOOT_TITLE")
	login_hint.text = tr("BOOT_HINT")
	login_user_label.text = tr("BOOT_USER")
	login_pass_label.text = tr("BOOT_PASS")
	login_ok.text = tr("BOOT_OK")
	login_cancel.text = tr("BOOT_CANCEL")

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
	loading_text.text = tr("BOOT_LOADING")
	var steps := [
		[0.15, "LOAD_KERNEL"],
		[0.40, "LOAD_GUI"],
		[0.65, "LOAD_MOUNT"],
		[0.85, "LOAD_PET"],
		[1.00, "LOAD_DONE"],
	]
	for s in steps:
		loading_bar.value = float(s[0]) * 100.0
		loading_text.text = tr(s[1])
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
