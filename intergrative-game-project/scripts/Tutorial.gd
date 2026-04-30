extends Control

@onready var title: Label = $Center/VBox/Title
@onready var goal: Label = $Center/VBox/Goal
@onready var move_label: Label = $Center/VBox/Lines/Move
@onready var action_label: Label = $Center/VBox/Lines/Action
@onready var focus_label: Label = $Center/VBox/Lines/Focus
@onready var pause_label: Label = $Center/VBox/Lines/Pause
@onready var task_label: Label = $Center/VBox/Lines/Task
@onready var perfect_label: Label = $Center/VBox/Lines/Perfect
@onready var fail_label: Label = $Center/VBox/Lines/Fail
@onready var tip_label: Label = $Center/VBox/Tip
@onready var start_btn: Button = $Center/VBox/Buttons/StartBtn
@onready var back_btn: Button = $Center/VBox/Buttons/BackBtn
@onready var click_sfx: AudioStreamPlayer = $ClickSFX

func _ready() -> void:
	_refresh_text()
	start_btn.pressed.connect(_on_start)
	back_btn.pressed.connect(_on_back)
	LanguageManager.language_changed.connect(func(_l): _refresh_text())
	start_btn.grab_focus()

func _refresh_text() -> void:
	title.text = tr("TUTORIAL_TITLE")
	goal.text = tr("TUTORIAL_GOAL")
	move_label.text = tr("TUTORIAL_MOVE")
	action_label.text = tr("TUTORIAL_ACTION")
	focus_label.text = tr("TUTORIAL_FOCUS")
	pause_label.text = tr("TUTORIAL_PAUSE")
	task_label.text = tr("TUTORIAL_TASK")
	perfect_label.text = tr("TUTORIAL_PERFECT")
	fail_label.text = tr("TUTORIAL_FAIL")
	tip_label.text = tr("TUTORIAL_TIP")
	start_btn.text = tr("START")
	back_btn.text = tr("BACK")

func _click() -> void:
	if click_sfx:
		click_sfx.play()

func _on_start() -> void:
	_click()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_back() -> void:
	_click()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
