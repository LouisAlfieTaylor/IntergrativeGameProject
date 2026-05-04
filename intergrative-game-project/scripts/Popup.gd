extends Panel

# A fake 90s ad popup that spawns during level 2. Player clicks X to close it.
# It does not add stress directly — it just covers up tasks until dismissed.

const POOL := [
	{ "title": "*** SPECIAL OFFER ***", "body": "YOU ARE THE 1,000,000th VISITOR!\nCLICK NOW TO CLAIM YOUR PRIZE!", "cta": "CLICK HERE!" },
	{ "title": "ALERT! ALERT!", "body": "Your PC is infected with\n47 viruses!\nDownload SUPER ANTIVIRUS now!", "cta": "FIX MY PC" },
	{ "title": "Hot Singles", "body": "Hot singles in your\nLOCAL AREA NETWORK\nare waiting to chat!", "cta": "CONNECT" },
	{ "title": "FREE INTERNET", "body": "GET FREE DIAL-UP\nFOREVER, NO STRINGS!\nSign up in 30 seconds!", "cta": "SIGN ME UP" },
	{ "title": "Money Maker", "body": "Make $5000/WEEK\nfrom HOME!\nThis ONE WEIRD TRICK", "cta": "TELL ME MORE" },
	{ "title": "Monkey", "body": "PUNCH the MONKEY\nand win an iPod!\n100% real, no scam.", "cta": "PUNCH IT" },
	{ "title": "WARNING", "body": "Your spreadsheet is\nbehind schedule!!!\nReview it now!", "cta": "REVIEW NOW" },
	{ "title": "EMERGENCY", "body": "The CEO needs you to\nrespond to a meme.\nIt is urgent.", "cta": "REPLY ALL" },
]

@onready var title_bar: Panel = $TitleBar
@onready var title_label: Label = $TitleBar/HBox/Title
@onready var close_btn: Button = $TitleBar/HBox/CloseBtn
@onready var body_label: Label = $Body
@onready var cta_btn: Button = $CTA

var _content: Dictionary = {}
var _drag_offset: Vector2 = Vector2.ZERO
var _dragging: bool = false

signal dismissed

func _ready() -> void:
	_content = POOL[randi() % POOL.size()]
	title_label.text = _content["title"]
	body_label.text = _content["body"]
	cta_btn.text = _content["cta"]
	close_btn.pressed.connect(_dismiss)
	cta_btn.pressed.connect(_on_cta)
	title_bar.gui_input.connect(_on_title_input)
	# Slide-in tween
	scale = Vector2(0.6, 0.6)
	modulate.a = 0.0
	pivot_offset = size / 2
	var t := create_tween().set_parallel(true)
	t.tween_property(self, "scale", Vector2(1, 1), 0.20).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "modulate:a", 1.0, 0.18)

func _on_cta() -> void:
	# CTA does the same as X — just dismisses with a slight twist
	_dismiss()

func _dismiss() -> void:
	dismissed.emit()
	var t := create_tween().set_parallel(true)
	t.tween_property(self, "scale", Vector2(0.6, 0.6), 0.18)
	t.tween_property(self, "modulate:a", 0.0, 0.18)
	t.chain().tween_callback(queue_free)

func _on_title_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_drag_offset = get_global_mouse_position() - position
		else:
			_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		var p = get_global_mouse_position() - _drag_offset
		# Clamp inside the parent rect (the SubViewport's size approximately)
		if get_parent() is Control:
			var parent_size: Vector2 = get_parent().size
			p.x = clamp(p.x, 0, max(0, parent_size.x - size.x))
			p.y = clamp(p.y, 0, max(0, parent_size.y - size.y))
		position = p
