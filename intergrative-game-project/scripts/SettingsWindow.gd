extends Panel

# A draggable settings window embedded in the desktop.

@onready var title_bar: Panel = $TitleBar
@onready var title_label: Label = $TitleBar/HBox/Title
@onready var close_btn: Button = $TitleBar/HBox/CloseBtn
@onready var lang_label: Label = $Content/VBox/Grid/LangLabel
@onready var lang_btn: Button = $Content/VBox/Grid/LangBtn
@onready var display_label: Label = $Content/VBox/Grid/DisplayLabel
@onready var display_btn: Button = $Content/VBox/Grid/DisplayBtn
@onready var music_label: Label = $Content/VBox/Grid/MusicLabel
@onready var music_slider: HSlider = $Content/VBox/Grid/MusicSlider
@onready var sfx_label: Label = $Content/VBox/Grid/SFXLabel
@onready var sfx_slider: HSlider = $Content/VBox/Grid/SFXSlider
@onready var tutorial_btn: Button = $Content/VBox/TutorialBtn
@onready var click_sfx: AudioStreamPlayer = $ClickSFX

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	music_slider.value = SettingsManager.music_volume
	sfx_slider.value = SettingsManager.sfx_volume
	_refresh_text()
	close_btn.pressed.connect(_on_close)
	lang_btn.pressed.connect(_on_lang)
	display_btn.pressed.connect(_on_display)
	music_slider.value_changed.connect(_on_music)
	sfx_slider.value_changed.connect(_on_sfx)
	tutorial_btn.pressed.connect(_on_tutorial)
	LanguageManager.language_changed.connect(func(_l): _refresh_text())
	title_bar.gui_input.connect(_on_title_input)

func _refresh_text() -> void:
	title_label.text = tr("SETTINGS")
	lang_label.text = tr("LANGUAGE") + ":"
	lang_btn.text = tr("ENGLISH") if LanguageManager.get_locale() == "en" else tr("FRENCH")
	display_label.text = tr("DISPLAY_MODE") + ":"
	display_btn.text = tr("FULLSCREEN") if SettingsManager.fullscreen else tr("WINDOWED")
	music_label.text = tr("MUSIC_VOLUME") + ":"
	sfx_label.text = tr("SFX_VOLUME") + ":"
	tutorial_btn.text = tr("SHOW_TUTORIAL")

func _click() -> void:
	if click_sfx:
		click_sfx.play()

func _on_close() -> void:
	_click()
	hide()

func _on_lang() -> void:
	_click()
	SettingsManager.toggle_locale()
	_refresh_text()

func _on_display() -> void:
	_click()
	SettingsManager.toggle_fullscreen()
	_refresh_text()

func _on_music(v: float) -> void:
	SettingsManager.set_music_volume(v)

func _on_sfx(v: float) -> void:
	SettingsManager.set_sfx_volume(v)

func _on_tutorial() -> void:
	_click()
	# Tell the desktop to play the tutorial via Buddy
	var lines := BuddyDialog.TUTORIAL_BODY.duplicate()
	lines.push_front(BuddyDialog.pick(BuddyDialog.TUTORIAL_INTRO))
	_play_chain(lines)

func _play_chain(lines: Array) -> void:
	if lines.is_empty():
		return
	# Pool items are translation keys — resolve before display.
	var key: String = lines.pop_front()
	Buddy.show_line(tr(key), func(): _play_chain(lines))

func _on_title_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_dragging = true
				_drag_offset = get_global_mouse_position() - position
			else:
				_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		position = get_global_mouse_position() - _drag_offset
		# Clamp to viewport
		var vp = get_viewport_rect().size
		position.x = clamp(position.x, 0, vp.x - size.x)
		position.y = clamp(position.y, 0, vp.y - size.y - 40)
