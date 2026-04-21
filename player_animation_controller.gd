extends Node

@onready var animation_player: AnimationPlayer = null
@onready var player: CharacterBody3D = get_parent()
@onready var footstep_audio = player.get_node_or_null("AudioStreamPlayer3D")

var current_animation = ""
const BLEND_TIME = 0.2

# Footstep timing based on animation
var footstep_intervals = {
	"Walk": 0.5,
	"Run": 0.35,
	"Sprint": 0.3,
	"Crouch_Walk": 0.7
}

var footstep_timer = 0.0
var current_interval = 0.5

func _ready():
	var model = player.get_node_or_null("CharacterModel")
	if model:
		animation_player = find_animation_player(model)
		if animation_player:
			print("AnimationPlayer found!")
			print("Available animations: ", animation_player.get_animation_list())
		else:
			print("AnimationPlayer not found in model")

func find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var result = find_animation_player(child)
		if result:
			return result
	return null

func _process(delta):
	if not animation_player or not player:
		return
	
	var target_animation = get_target_animation()
	
	if target_animation != current_animation:
		if animation_player.has_animation(target_animation):
			if current_animation != "":
				animation_player.play(target_animation, BLEND_TIME)
			else:
				animation_player.play(target_animation)
			current_animation = target_animation
			
			# Update footstep interval based on animation
			if target_animation in footstep_intervals:
				current_interval = footstep_intervals[target_animation]
	
	# Handle animation-synced footsteps
	handle_footsteps(delta)

func handle_footsteps(delta):
	if not player.is_on_floor():
		footstep_timer = 0.0
		return
	
	var horizontal_speed = Vector2(player.velocity.x, player.velocity.z).length()
	if horizontal_speed < 0.1:
		footstep_timer = 0.0
		return
	
	footstep_timer += delta
	
	if footstep_timer >= current_interval:
		play_footstep()
		footstep_timer = 0.0

func play_footstep():
	if footstep_audio:
		footstep_audio.play_footstep()

func get_target_animation() -> String:
	var horizontal_speed = Vector2(player.velocity.x, player.velocity.z).length()
	
	if player.is_rolling:
		return "Roll"
	
	if not player.is_on_floor():
		if player.velocity.y > 0:
			return "Jump_Start"
		else:
			return "Jump"
	
	if player.is_crouching:
		if horizontal_speed > 0.1:
			return "Crouch_Fwd"
		else:
			return "Crouch_Idle"
	
	if player.is_sprinting and horizontal_speed > 0.1:
		return "Sprint"
	
	if horizontal_speed > 0.1:
		return "Walk"
	
	return "Idle"
