extends Control

@onready var title: Label = $Center/VBox/Title
@onready var message: Label = $Center/VBox/Message
@onready var score_label: Label = $Center/VBox/Stats/ScoreLabel
@onready var tasks_label: Label = $Center/VBox/Stats/TasksLabel
@onready var restart_btn: Button = $Center/VBox/Buttons/RestartBtn
@onready var menu_btn: Button = $Center/VBox/Buttons/MenuBtn
@onready var click_sfx: AudioStreamPlayer = $ClickSFX

func _ready() -> void:
	_refresh_text()
	restart_btn.pressed.connect(_on_restart)
	menu_btn.pressed.connect(_on_menu)
	LanguageManager.language_changed.connect(func(_l): _refresh_text())
	if GameState.won:
		title.modulate = Color(0.85, 1, 0.85)
	else:
		title.modulate = Color(1, 0.7, 0.7)
	restart_btn.grab_focus()
	# Buddy reaction
	await get_tree().create_timer(0.4, true).timeout
	if GameState.won:
		Buddy.show_from_pool(BuddyDialog.WIN_CONGRATS)
	else:
		Buddy.show_from_pool(BuddyDialog.LOSE_COMFORT)

func _refresh_text() -> void:
	if GameState.won:
		title.text = tr("WIN_TITLE")
		message.text = tr("WIN_MSG")
	else:
		title.text = tr("LOSE_TITLE")
		message.text = tr("LOSE_MSG")
	score_label.text = "%s: %d" % [tr("FINAL_SCORE"), GameState.final_score]
	tasks_label.text = "%s: %d" % [tr("TASKS_DONE"), GameState.tasks_completed]
	restart_btn.text = tr("RESTART")
	menu_btn.text = tr("MAIN_MENU")

func _click() -> void:
	if click_sfx:
		click_sfx.play()

func _on_restart() -> void:
	_click()
	GameState.start_new_run()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_menu() -> void:
	_click()
	get_tree().change_scene_to_file("res://scenes/Desktop.tscn")
