extends Control

@onready var title: Label = $Center/VBox/Title
@onready var subtitle: Label = $Center/VBox/Subtitle
@onready var play_btn: Button = $Center/VBox/Buttons/PlayBtn
@onready var tutorial_btn: Button = $Center/VBox/Buttons/TutorialBtn
@onready var settings_btn: Button = $Center/VBox/Buttons/SettingsBtn
@onready var quit_btn: Button = $Center/VBox/Buttons/QuitBtn
@onready var lang_btn: Button = $TopRight/LangBtn
@onready var click_sfx: AudioStreamPlayer = $ClickSFX

func _ready() -> void:
	_refresh_text()
	play_btn.pressed.connect(_on_play)
	tutorial_btn.pressed.connect(_on_tutorial)
	settings_btn.pressed.connect(_on_settings)
	quit_btn.pressed.connect(_on_quit)
	lang_btn.pressed.connect(_on_toggle_lang)
	LanguageManager.language_changed.connect(func(_l): _refresh_text())
	play_btn.grab_focus()

func _refresh_text() -> void:
	title.text = tr("TITLE")
	subtitle.text = tr("SUBTITLE")
	play_btn.text = tr("PLAY")
	tutorial_btn.text = tr("TUTORIAL")
	settings_btn.text = tr("SETTINGS")
	quit_btn.text = tr("QUIT")
	lang_btn.text = LanguageManager.get_locale().to_upper()

func _click() -> void:
	if click_sfx:
		click_sfx.play()

func _on_play() -> void:
	_click()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_tutorial() -> void:
	_click()
	get_tree().change_scene_to_file("res://scenes/Tutorial.tscn")

func _on_settings() -> void:
	_click()
	get_tree().change_scene_to_file("res://scenes/Settings.tscn")

func _on_quit() -> void:
	_click()
	get_tree().quit()

func _on_toggle_lang() -> void:
	_click()
	SettingsManager.toggle_locale()
