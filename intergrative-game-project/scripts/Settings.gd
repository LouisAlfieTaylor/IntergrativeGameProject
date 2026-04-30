extends Control

@onready var title: Label = $Center/VBox/Title
@onready var lang_label: Label = $Center/VBox/LangRow/Label
@onready var lang_btn: Button = $Center/VBox/LangRow/Button
@onready var display_label: Label = $Center/VBox/DisplayRow/Label
@onready var display_btn: Button = $Center/VBox/DisplayRow/Button
@onready var music_label: Label = $Center/VBox/MusicRow/Label
@onready var music_slider: HSlider = $Center/VBox/MusicRow/Slider
@onready var sfx_label: Label = $Center/VBox/SFXRow/Label
@onready var sfx_slider: HSlider = $Center/VBox/SFXRow/Slider
@onready var back_btn: Button = $Center/VBox/BackBtn
@onready var click_sfx: AudioStreamPlayer = $ClickSFX

func _ready() -> void:
	music_slider.value = SettingsManager.music_volume
	sfx_slider.value = SettingsManager.sfx_volume
	_refresh_text()
	lang_btn.pressed.connect(_on_lang)
	display_btn.pressed.connect(_on_display)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	back_btn.pressed.connect(_on_back)
	LanguageManager.language_changed.connect(func(_l): _refresh_text())
	back_btn.grab_focus()

func _refresh_text() -> void:
	title.text = tr("SETTINGS")
	lang_label.text = tr("LANGUAGE")
	lang_btn.text = tr("ENGLISH") if LanguageManager.get_locale() == "en" else tr("FRENCH")
	display_label.text = tr("DISPLAY_MODE")
	display_btn.text = tr("FULLSCREEN") if SettingsManager.fullscreen else tr("WINDOWED")
	music_label.text = tr("MUSIC_VOLUME")
	sfx_label.text = tr("SFX_VOLUME")
	back_btn.text = tr("BACK")

func _click() -> void:
	if click_sfx:
		click_sfx.play()

func _on_lang() -> void:
	_click()
	SettingsManager.toggle_locale()
	_refresh_text()

func _on_display() -> void:
	_click()
	SettingsManager.toggle_fullscreen()
	_refresh_text()

func _on_music_changed(v: float) -> void:
	SettingsManager.set_music_volume(v)

func _on_sfx_changed(v: float) -> void:
	SettingsManager.set_sfx_volume(v)
	if click_sfx and not click_sfx.playing:
		click_sfx.play()

func _on_back() -> void:
	_click()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
