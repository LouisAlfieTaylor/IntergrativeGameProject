extends Node

const SAVE_PATH := "user://settings.cfg"

signal settings_changed

var fullscreen: bool = false
var music_volume: float = 0.7
var sfx_volume: float = 0.85
var locale: String = "en"

func _ready() -> void:
	var layout = load("res://default_bus_layout.tres")
	if layout:
		AudioServer.set_bus_layout(layout)
	load_settings()
	apply_all()

func apply_all() -> void:
	apply_window_mode()
	apply_audio()
	LanguageManager.set_locale(locale)

func apply_window_mode() -> void:
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func apply_audio() -> void:
	_set_bus_volume("Music", music_volume)
	_set_bus_volume("SFX", sfx_volume)

func _set_bus_volume(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	if linear <= 0.0001:
		AudioServer.set_bus_mute(idx, true)
	else:
		AudioServer.set_bus_mute(idx, false)
		AudioServer.set_bus_volume_db(idx, linear_to_db(linear))

func toggle_fullscreen() -> void:
	fullscreen = not fullscreen
	apply_window_mode()
	save_settings()
	settings_changed.emit()

func set_music_volume(v: float) -> void:
	music_volume = clamp(v, 0.0, 1.0)
	_set_bus_volume("Music", music_volume)
	save_settings()
	settings_changed.emit()

func set_sfx_volume(v: float) -> void:
	sfx_volume = clamp(v, 0.0, 1.0)
	_set_bus_volume("SFX", sfx_volume)
	save_settings()
	settings_changed.emit()

func set_locale(loc: String) -> void:
	locale = loc
	LanguageManager.set_locale(loc)
	save_settings()
	settings_changed.emit()

func toggle_locale() -> void:
	LanguageManager.toggle_locale()
	locale = LanguageManager.get_locale()
	save_settings()
	settings_changed.emit()

func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("display", "fullscreen", fullscreen)
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.set_value("lang", "locale", locale)
	cfg.save(SAVE_PATH)

func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	fullscreen = cfg.get_value("display", "fullscreen", false)
	music_volume = cfg.get_value("audio", "music", 0.7)
	sfx_volume = cfg.get_value("audio", "sfx", 0.85)
	locale = cfg.get_value("lang", "locale", "en")
