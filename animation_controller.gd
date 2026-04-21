extends Node

@onready var animation_player = get_node("../Model/AnimationPlayer")
@onready var player = get_parent()

var current_animation = ""

func _ready():
	if animation_player:
		print("Available animations: ", animation_player.get_animation_list())

func _process(_delta):
	if not animation_player or not player:
		return
	
	var target_animation = "Idle"
	
	# Check player state
	if not player.is_on_floor():
		target_animation = "Jump"
	elif player.is_crouching:
		if player.velocity.length() > 0.1:
			target_animation = "Crouch_Walk"
		else:
			target_animation = "Crouch_Idle"
	elif player.is_sprinting and player.velocity.length() > 0.1:
		target_animation = "Run"
	elif player.velocity.length() > 0.1:
		target_animation = "Walk"
	else:
		target_animation = "Idle"
	
	# Play animation if changed
	if target_animation != current_animation:
		if animation_player.has_animation(target_animation):
			animation_player.play(target_animation)
			current_animation = target_animation
