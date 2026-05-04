extends CanvasLayer

@onready var time_label: Label = $Root/Top/TimePanel/TimeLabel
@onready var score_label: Label = $Root/Top/ScorePanel/ScoreLabel
@onready var stress_label: Label = $Root/Top/StressPanel/VBox/Title
@onready var stress_bar: ProgressBar = $Root/Top/StressPanel/VBox/Bar
@onready var focus_label: Label = $Root/Bottom/FocusPanel/VBox/Title
@onready var focus_bar: ProgressBar = $Root/Bottom/FocusPanel/VBox/Bar
@onready var popup: Label = $Root/Popup
@onready var burst_indicator: Label = $Root/BurstIndicator
@onready var level_label: Label = $Root/Top/StressPanel/VBox/LevelLabel

var _popup_tween: Tween

func _ready() -> void:
	popup.modulate.a = 0.0
	burst_indicator.visible = false
	_refresh_text()
	LanguageManager.language_changed.connect(func(_l): _refresh_text())

func _refresh_text() -> void:
	stress_label.text = tr("STRESS")
	focus_label.text = tr("FOCUS")

func set_time_left(seconds: float) -> void:
	var s = int(ceil(seconds))
	var m = s / 60
	var rs = s % 60
	time_label.text = "%s  %02d:%02d" % [tr("TIME"), m, rs]

func set_level(current: int, total: int) -> void:
	if level_label:
		level_label.text = "LEVEL %d / %d" % [current, total]

func set_score(value: int) -> void:
	score_label.text = "%s  %d" % [tr("SCORE"), value]

func set_stress(value: float, max_value: float) -> void:
	stress_bar.max_value = max_value
	stress_bar.value = value
	stress_bar.modulate = Color(1, 1, 1).lerp(Color(1, 0.55, 0.55), value / max_value)

func set_focus(value: float, max_value: float) -> void:
	focus_bar.max_value = max_value
	focus_bar.value = value

func show_popup(text: String) -> void:
	popup.text = text
	popup.modulate.a = 1.0
	popup.scale = Vector2(0.7, 0.7)
	if _popup_tween and _popup_tween.is_valid():
		_popup_tween.kill()
	_popup_tween = create_tween().set_parallel(true)
	_popup_tween.tween_property(popup, "scale", Vector2(1.05, 1.05), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_popup_tween.tween_property(popup, "modulate:a", 0.0, 0.9).set_delay(0.4)
	_popup_tween.tween_property(popup, "scale", Vector2(0.95, 0.95), 0.6).set_delay(0.4)

func show_focus_burst(_duration: float) -> void:
	burst_indicator.text = tr("FOCUS")
	burst_indicator.visible = true
	burst_indicator.modulate = Color(0.6, 0.95, 1.0, 1)

func hide_focus_burst() -> void:
	burst_indicator.visible = false
