extends RefCounted
class_name BuddyDialog

# Pools of translation KEYS for buddy lines. Buddy.gd resolves them via tr()
# at display time, so French players see French.

const TUTORIAL_INTRO := [
	"BUDDY_INTRO_1", "BUDDY_INTRO_2", "BUDDY_INTRO_3", "BUDDY_INTRO_4",
	"BUDDY_INTRO_5", "BUDDY_INTRO_6", "BUDDY_INTRO_7", "BUDDY_INTRO_8",
]

const TUTORIAL_BODY := [
	"BUDDY_BODY_1", "BUDDY_BODY_2", "BUDDY_BODY_3", "BUDDY_BODY_4", "BUDDY_BODY_5",
]

const FIRST_BOOT := [
	"BUDDY_FIRSTBOOT_1", "BUDDY_FIRSTBOOT_2", "BUDDY_FIRSTBOOT_3",
]

const REACT_MISS := [
	"BUDDY_MISS_1", "BUDDY_MISS_2", "BUDDY_MISS_3", "BUDDY_MISS_4", "BUDDY_MISS_5",
	"BUDDY_MISS_6", "BUDDY_MISS_7", "BUDDY_MISS_8", "BUDDY_MISS_9", "BUDDY_MISS_10",
]

const REACT_PERFECT := [
	"BUDDY_PERFECT_1", "BUDDY_PERFECT_2", "BUDDY_PERFECT_3", "BUDDY_PERFECT_4", "BUDDY_PERFECT_5",
	"BUDDY_PERFECT_6", "BUDDY_PERFECT_7", "BUDDY_PERFECT_8", "BUDDY_PERFECT_9", "BUDDY_PERFECT_10",
]

const BETWEEN_LEVELS := [
	"BUDDY_BETWEEN_1", "BUDDY_BETWEEN_2", "BUDDY_BETWEEN_3", "BUDDY_BETWEEN_4", "BUDDY_BETWEEN_5",
	"BUDDY_BETWEEN_6", "BUDDY_BETWEEN_7", "BUDDY_BETWEEN_8", "BUDDY_BETWEEN_9", "BUDDY_BETWEEN_10",
]

const APP_NAG := [
	"BUDDY_NAG_1", "BUDDY_NAG_2", "BUDDY_NAG_3", "BUDDY_NAG_4", "BUDDY_NAG_5",
	"BUDDY_NAG_6", "BUDDY_NAG_7", "BUDDY_NAG_8", "BUDDY_NAG_9", "BUDDY_NAG_10",
]

const APP_NAG_RECYCLE := [
	"BUDDY_RECYCLE_1", "BUDDY_RECYCLE_2", "BUDDY_RECYCLE_3", "BUDDY_RECYCLE_4",
]

const APP_NAG_BROWSER := [
	"BUDDY_BROWSER_1", "BUDDY_BROWSER_2", "BUDDY_BROWSER_3", "BUDDY_BROWSER_4",
]

const QUIT_CONFIRM := [
	"BUDDY_QUITDESK_1", "BUDDY_QUITDESK_2", "BUDDY_QUITDESK_3", "BUDDY_QUITDESK_4",
]

const WIN_CONGRATS := [
	"BUDDY_WIN_1", "BUDDY_WIN_2", "BUDDY_WIN_3", "BUDDY_WIN_4",
]

const LOSE_COMFORT := [
	"BUDDY_LOSE_1", "BUDDY_LOSE_2", "BUDDY_LOSE_3", "BUDDY_LOSE_4",
]

static func pick(pool: Array, last: String = "") -> String:
	var choices = pool.duplicate()
	if last != "" and last in choices and choices.size() > 1:
		choices.erase(last)
	return choices[randi() % choices.size()]
