extends RefCounted
class_name BuddyDialog

# Pools of dialogue lines per situation. Used by Buddy.gd to pick a random line
# without repeating the most recent one. Translation keys are resolved via tr().

const TUTORIAL_INTRO := [
	"Hey there! I'm Floppy. Welcome to your shift!",
	"Look at you! First day on the job. Let's get you set up!",
	"Hi pal! Ready to crunch some tasks today?",
	"Beep boop! Floppy here, your friendly assistant!",
	"Welcome welcome! Let me show you the ropes.",
	"Hi! I'll be popping up to help when you need it. Or just to chat!",
	"Look who finally booted up the game! Hi!",
	"It's me, Floppy! I'll be your guide for today.",
]

const TUTORIAL_BODY := [
	"Use the arrow keys or WASD to wander around the office.",
	"When a task icon appears, walk up to it and press SPACE.",
	"Tap SPACE again when the marker is in the GREEN zone — perfect timing!",
	"Holding SHIFT lets you slow time. Use it when things pile up!",
	"If you miss too many tasks, your stress meter fills up. Don't burn out!",
]

const FIRST_BOOT := [
	"Whew, you made it! Let's get to work.",
	"Welcome to your first shift! Don't worry, I'll be around.",
	"Hi! Big day today. Want to know how this all works?",
]

# Reactions when the player misses or expires a task (rare in-level)
const REACT_MISS := [
	"Yikes! Don't sweat it, you've got this.",
	"Oof. Shake it off, champ!",
	"That one got away! Onto the next.",
	"Don't worry, even pros miss sometimes.",
	"It's fine! Honestly! I wasn't even looking.",
	"Whoops-a-daisy! Try to relax.",
	"Hey hey hey — eyes on the next one.",
	"That's nothing! You're still doing great.",
	"Bah, that one was rigged. I saw it.",
	"Plot twist! You'll get the next ten in a row.",
]

# Reactions when the player nails a perfect task (rare in-level)
const REACT_PERFECT := [
	"BAM! That was beautiful!",
	"Sheesh, you're on fire today!",
	"Now THAT is professional work!",
	"Did you SEE that? I saw that!",
	"Ten out of ten. Hire this person!",
	"You're making me look bad!",
	"Buddy, that was poetry in motion.",
	"Outstanding! Keep it rolling!",
	"That was a corporate KPI miracle.",
	"Floppy seal of approval!",
]

# Between-level pep talks
const BETWEEN_LEVELS := [
	"Round one done! Stretch those fingers.",
	"Nice work! Ready for the next one?",
	"Phew, what a shift. Let's keep the momentum!",
	"Onwards and upwards! Next level coming up.",
	"You're doing amazing. Get ready, it gets spicy.",
	"Quick break, then back at it. You've got this!",
	"Look at you go! Don't slow down now.",
	"Catch your breath. Next round's about to start.",
	"That was a warm-up. Real work starts now!",
	"Halfway there or all the way? Only one way to find out!",
]

# When the player clicks a non-game app on the desktop
const APP_NAG := [
	"Hey! That's not the game. Crunch Time is the briefcase icon!",
	"Easy there, that one's just a placeholder. The game's over here!",
	"I'd love to let you, but our budget didn't cover that app.",
	"Boring! Click Crunch Time. That's where the fun lives.",
	"Pssst, that icon is decoration. Try the briefcase!",
	"Click click click — but not THAT one! Try the game!",
	"You wouldn't BELIEVE how broken that app is. Skip it!",
	"That's a Windows joke we couldn't afford. Crunch Time, please!",
	"Oh sweetie no. The game is the briefcase. Believe me.",
	"That app has a virus. Probably. Don't risk it!",
]

const APP_NAG_RECYCLE := [
	"The trash is empty. Mostly because there's nothing in it.",
	"You're really committed to this trash bit, huh?",
	"Hey, that's just a 16x16 icon. There's nothing inside.",
	"Stop poking the trash can! It's empty!",
]

const APP_NAG_BROWSER := [
	"It's 1998 in here, the internet is dial-up only. Skip it.",
	"Loading... loading... still loading... yeah, no.",
	"You'd just get pop-up ads. I'm sparing you!",
	"Internet Distract is closed. Crunch Time is open!",
]

const QUIT_CONFIRM := [
	"Aw, leaving so soon? I'll save your spot!",
	"Going already? Floppy will miss you!",
	"Ok. Ok ok. I'll be here. Always.",
	"Bye for now! Reboot whenever you want.",
]

const WIN_CONGRATS := [
	"You did it! Whole shift, all yours!",
	"Wooo! Take that, deadlines!",
	"Top of the floppy class! Well done!",
	"Crunch Time crunched! Beautiful.",
]

const LOSE_COMFORT := [
	"Oh no, the stress got you. Take a breath, try again!",
	"That's burnout, buddy. We've all been there.",
	"Don't blame yourself. The corporate grind is HARD.",
	"Round again? I believe in you!",
]

static func pick(pool: Array, last: String = "") -> String:
	var choices = pool.duplicate()
	if last != "" and last in choices and choices.size() > 1:
		choices.erase(last)
	return choices[randi() % choices.size()]
