extends Node

@onready var animation_player: AnimationPlayer = null
@onready var player: CharacterBody3D = get_parent()

var is_emoting = false
var emote_timer = 0.0

# Available emotes from UAL1
var emotes = {
	"dance": "Dance",
	"wave": "Interact",
	"sit": "Sitting_Idle",
	"death": "Death01",
	"punch": "Punch_Jab"
}

func _ready():
	var model = player.get_node_or_null("CharacterModel")
	if model:
		animation_player = find_animation_player(model)
		if animation_player:
			print("Emote System Ready!")
			print("Press 1-6 for emotes")

func find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var result = find_animation_player(child)
		if result:
			return result
	return null

func _input(event):
	if not animation_player:
		return
	
	# Emote hotkeys
	if event.is_action_pressed("emote_1"):
		play_emote("dance")
	elif event.is_action_pressed("emote_2"):
		play_emote("wave")
	elif event.is_action_pressed("emote_3"):
		play_emote("sit")
	elif event.is_action_pressed("emote_4"):
		play_emote("death")
	elif event.is_action_pressed("emote_5"):
		play_emote("punch")
	
	# Cancel emote with any movement key
	if is_emoting:
		if event.is_action_pressed("move_forward") or event.is_action_pressed("move_back") or \
		   event.is_action_pressed("move_left") or event.is_action_pressed("move_right") or \
		   event.is_action_pressed("ui_accept"):
			cancel_emote()

func play_emote(emote_name: String):
	if emote_name in emotes and animation_player.has_animation(emotes[emote_name]):
		is_emoting = true
		animation_player.play(emotes[emote_name])
		print("Playing emote: ", emote_name)
		
		# Auto-cancel after animation finishes
		var anim_length = animation_player.get_animation(emotes[emote_name]).length
		emote_timer = anim_length

func cancel_emote():
	is_emoting = false
	emote_timer = 0.0
	print("Emote cancelled")

func _process(delta):
	if is_emoting:
		emote_timer -= delta
		if emote_timer <= 0:
			is_emoting = false

func is_playing_emote() -> bool:
	return is_emoting
