extends Control

@onready var title: Label = $VBox/Title
@onready var resume_btn: Button = $VBox/ResumeBtn
@onready var restart_btn: Button = $VBox/RestartBtn
@onready var menu_btn: Button = $VBox/MenuBtn

func _ready() -> void:
	_refresh_text()
	resume_btn.pressed.connect(_on_resume)
	restart_btn.pressed.connect(_on_restart)
	menu_btn.pressed.connect(_on_main_menu)
	LanguageManager.language_changed.connect(func(_l): _refresh_text())

func _refresh_text() -> void:
	title.text = tr("PAUSED")
	resume_btn.text = tr("RESUME")
	restart_btn.text = tr("RESTART")
	menu_btn.text = tr("MAIN_MENU")

func _on_resume() -> void:
	var game = get_tree().current_scene
	if game and game.has_method("resume"):
		game.resume()

func _on_restart() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
