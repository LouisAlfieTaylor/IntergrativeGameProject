extends Control

# Shown between levels. Buddy gives a pep talk, then we move to the next round.

@onready var level_label: Label = $Center/VBox/LevelLabel
@onready var hint_label: Label = $Center/VBox/Hint
@onready var continue_btn: Button = $Center/VBox/ContinueBtn

var _can_continue: bool = false

func _ready() -> void:
	level_label.text = "LEVEL %d / %d" % [GameState.current_level, GameState.TOTAL_LEVELS]
	hint_label.text = "Catch your breath..."
	continue_btn.text = "Start Level"
	continue_btn.pressed.connect(_on_continue)
	# Buddy speaks the pep talk, then we let the player continue
	await get_tree().create_timer(0.4, true).timeout
	Buddy.show_from_pool(BuddyDialog.BETWEEN_LEVELS, func(): _allow_continue())

func _allow_continue() -> void:
	_can_continue = true
	hint_label.text = "Press SPACE or click to start the next level."
	continue_btn.grab_focus()

func _input(event: InputEvent) -> void:
	if _can_continue and event.is_action_pressed("action"):
		_on_continue()

func _on_continue() -> void:
	if not _can_continue:
		return
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
