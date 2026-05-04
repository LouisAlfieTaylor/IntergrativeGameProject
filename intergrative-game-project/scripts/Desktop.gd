extends Control

# Win 95-style desktop. Replaces the old MainMenu as the main hub.

const FIRST_BOOT_KEY := "first_boot_shown"

@onready var clock_label: Label = $Taskbar/HBox/ClockPanel/Clock
@onready var start_btn: Button = $Taskbar/HBox/StartBtn
@onready var settings_window: Panel = $Windows/SettingsWindow
@onready var click_sfx: AudioStreamPlayer = $ClickSFX
@onready var icon_grid: VBoxContainer = $IconGrid

var _clock_timer: Timer
var _tutorial_played_this_session := false

func _ready() -> void:
	_clock_timer = Timer.new()
	_clock_timer.wait_time = 1.0
	_clock_timer.autostart = true
	_clock_timer.timeout.connect(_update_clock)
	add_child(_clock_timer)
	_update_clock()

	# Wire all icons (each is a TextureButton or Button with metadata for what it does)
	for icon in icon_grid.get_children():
		if icon is Button:
			var act = icon.get_meta("action", "nag")
			icon.pressed.connect(func(): _on_icon_clicked(act, icon.get_meta("nag_pool", "default")))

	start_btn.pressed.connect(_on_start)

	# Settings window is already open on arrival, per design
	settings_window.show()

	# First-boot tutorial nudge from Buddy
	await get_tree().create_timer(0.6, true).timeout
	if not GameState.has_seen_tutorial:
		GameState.mark_tutorial_seen()
		_play_first_boot_intro()

func _update_clock() -> void:
	var t = Time.get_time_dict_from_system()
	var hour: int = t.hour
	var ampm := "AM" if hour < 12 else "PM"
	hour = hour % 12
	if hour == 0:
		hour = 12
	clock_label.text = "%d:%02d %s" % [hour, t.minute, ampm]

func _click() -> void:
	if click_sfx:
		click_sfx.play()

func _on_icon_clicked(action: String, nag_pool: String) -> void:
	_click()
	match action:
		"play":
			_launch_game()
		"settings":
			settings_window.show()
		"tutorial":
			_play_tutorial()
		"quit":
			Buddy.show_from_pool(BuddyDialog.QUIT_CONFIRM, func(): get_tree().quit())
		"nag":
			_nag(nag_pool)
		_:
			_nag("default")

func _nag(pool_name: String) -> void:
	var pool: Array = BuddyDialog.APP_NAG
	match pool_name:
		"recycle":
			pool = BuddyDialog.APP_NAG_RECYCLE
		"browser":
			pool = BuddyDialog.APP_NAG_BROWSER
		_:
			pool = BuddyDialog.APP_NAG
	Buddy.show_from_pool(pool)

func _launch_game() -> void:
	# Reset to level 1 when launching from desktop
	GameState.start_new_run()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _play_first_boot_intro() -> void:
	if _tutorial_played_this_session:
		return
	_tutorial_played_this_session = true
	# Chain: greeting -> body -> body -> body
	var lines: Array = []
	lines.append(BuddyDialog.pick(BuddyDialog.FIRST_BOOT))
	for body in BuddyDialog.TUTORIAL_BODY:
		lines.append(body)
	_play_chain(lines)

func _play_tutorial() -> void:
	var lines := BuddyDialog.TUTORIAL_BODY.duplicate()
	lines.push_front(BuddyDialog.pick(BuddyDialog.TUTORIAL_INTRO))
	_play_chain(lines)

func _play_chain(lines: Array) -> void:
	if lines.is_empty():
		return
	var line: String = lines.pop_front()
	Buddy.show_line(line, func(): _play_chain(lines))

func _on_start() -> void:
	_click()
	# The Start menu is just a nag for now, encouraging them to play
	Buddy.show_line("Start menu? Just play the game! It's the briefcase!")
