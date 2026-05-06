extends CanvasLayer

# Floppy the buddy. Pops in, says a thing, pops out.
# Use as autoload: Buddy.show_line("...") or Buddy.show_from_pool(BuddyDialog.REACT_MISS)

const TYPE_INTERVAL := 0.035  # seconds per character
const VOICE_EVERY_N_CHARS := 3
const HIDE_AFTER_FINISH := 1.6  # auto-hide delay after typing finishes

# Voice samples are explicit preloads (not dynamic load) so Godot's export
# scanner detects them as dependencies and bundles the WAVs in the .pck.
const VOICE_STREAMS := [
	preload("res://assets/audio/voice/voice_ba.wav"),
	preload("res://assets/audio/voice/voice_bo.wav"),
	preload("res://assets/audio/voice/voice_do.wav"),
	preload("res://assets/audio/voice/voice_ka.wav"),
	preload("res://assets/audio/voice/voice_la.wav"),
	preload("res://assets/audio/voice/voice_mi.wav"),
	preload("res://assets/audio/voice/voice_ne.wav"),
	preload("res://assets/audio/voice/voice_po.wav"),
	preload("res://assets/audio/voice/voice_yu.wav"),
	preload("res://assets/audio/voice/voice_zi.wav"),
]

signal finished

@onready var root: Control = $Root
@onready var anchor: Control = $Root/Anchor
@onready var bubble: PanelContainer = $Root/Anchor/Bubble
@onready var bubble_label: Label = $Root/Anchor/Bubble/MarginContainer/Label
@onready var visual: Node2D = $Root/Anchor/CharHolder/CharVisual
@onready var char_holder: Node2D = $Root/Anchor/CharHolder
@onready var hide_timer: Timer = $HideTimer

var _voice_players: Array[AudioStreamPlayer] = []
var _voice_streams: Array[AudioStream] = []
var _full_text: String = ""
var _typed_chars: int = 0
var _typing: bool = false
var _last_line: Dictionary = {}  # pool_id -> last line said
var _bob_t: float = 0.0
var _on_done_cb: Callable = Callable()

func _ready() -> void:
	# Force this CanvasLayer to render above everything (and ignore pause)
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	root.visible = false
	bubble_label.text = ""
	hide_timer.one_shot = true
	hide_timer.timeout.connect(_on_hide_timer)
	_load_voice_streams()

func _process(delta: float) -> void:
	if not root.visible:
		return
	# Bob the character up and down gently
	_bob_t += delta * 4.0
	char_holder.position.y = sin(_bob_t) * 4.0
	# Mouth animation while typing
	if _typing:
		visual.set_mouth_open(int(_bob_t * 8.0) % 2 == 0)

const _VOICE_PATHS: Array[String] = [
	"res://assets/audio/voice/voice_ba.wav",
	"res://assets/audio/voice/voice_bo.wav",
	"res://assets/audio/voice/voice_do.wav",
	"res://assets/audio/voice/voice_ka.wav",
	"res://assets/audio/voice/voice_la.wav",
	"res://assets/audio/voice/voice_mi.wav",
	"res://assets/audio/voice/voice_ne.wav",
	"res://assets/audio/voice/voice_po.wav",
	"res://assets/audio/voice/voice_yu.wav",
	"res://assets/audio/voice/voice_zi.wav",
]

func _load_voice_streams() -> void:
	# Use the precompiled list — works in both dev and exported builds.
	for s in VOICE_STREAMS:
		if s != null:
			_voice_streams.append(s)
	# Pre-allocate a small pool of players for overlap
	for i in 4:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_voice_players.append(p)

func show_line(text: String, on_done: Callable = Callable()) -> void:
	_full_text = text
	_typed_chars = 0
	_on_done_cb = on_done
	bubble_label.text = ""
	root.visible = true
	_typing = true
	hide_timer.stop()
	# Slide-in tween
	root.modulate.a = 0.0
	char_holder.position = Vector2(40, 30)
	var t := create_tween().set_parallel(true)
	t.tween_property(root, "modulate:a", 1.0, 0.2)
	t.tween_property(char_holder, "position", Vector2(0, 0), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_type_loop()

func show_from_pool(pool: Array, on_done: Callable = Callable()) -> void:
	# Pool entries are translation keys; resolve via tr() before display.
	# Track last picked KEY (not the translated text) so re-rolls are stable
	# across language changes.
	var pool_id := str(pool.hash())
	var last_key = _last_line.get(pool_id, "")
	var key: String = BuddyDialog.pick(pool, last_key)
	_last_line[pool_id] = key
	show_line(tr(key), on_done)

func _type_loop() -> void:
	while _typing and _typed_chars < _full_text.length():
		_typed_chars += 1
		bubble_label.text = _full_text.substr(0, _typed_chars)
		# Play a voice blip every few characters (skip whitespace)
		var c := _full_text[_typed_chars - 1]
		if _typed_chars % VOICE_EVERY_N_CHARS == 0 and c != " " and c != "." and c != "," and c != "!" and c != "?":
			_play_blip()
		await get_tree().create_timer(TYPE_INTERVAL, true, false, true).timeout
		if not _typing:
			return  # got hidden mid-type
	_typing = false
	visual.set_mouth_open(false)
	hide_timer.start(HIDE_AFTER_FINISH)

func _play_blip() -> void:
	if _voice_streams.is_empty():
		return
	# Find a free player or steal one
	var player: AudioStreamPlayer = null
	for p in _voice_players:
		if not p.playing:
			player = p
			break
	if player == null:
		player = _voice_players[randi() % _voice_players.size()]
	player.stream = _voice_streams[randi() % _voice_streams.size()]
	player.pitch_scale = randf_range(0.85, 1.25)
	player.volume_db = -4.0
	player.play()

func _on_hide_timer() -> void:
	dismiss()

func dismiss() -> void:
	if not root.visible:
		return
	_typing = false
	visual.set_mouth_open(false)
	var t := create_tween().set_parallel(true)
	t.tween_property(root, "modulate:a", 0.0, 0.25)
	t.tween_property(char_holder, "position", Vector2(40, 30), 0.25)
	t.chain().tween_callback(func():
		root.visible = false
		_call_done())

func _call_done() -> void:
	finished.emit()
	if _on_done_cb.is_valid():
		var cb := _on_done_cb
		_on_done_cb = Callable()
		cb.call()

func skip_or_hide() -> void:
	# If typing: jump to end. If finished: hide now.
	if _typing:
		_typing = false
		bubble_label.text = _full_text
		visual.set_mouth_open(false)
		hide_timer.start(0.6)
	else:
		hide_timer.stop()
		dismiss()
