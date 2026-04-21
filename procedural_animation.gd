extends Node

# Procedural Animation System
# Creates simple animations by manipulating skeleton bones directly

@onready var skeleton: Skeleton3D = null
@onready var player: CharacterBody3D = get_parent()

var time = 0.0
var current_state = "idle"

# Bone indices (will be found at runtime)
var spine_bone = -1
var head_bone = -1
var left_arm_bone = -1
var right_arm_bone = -1
var left_leg_bone = -1
var right_leg_bone = -1

func _ready():
	var model = player.get_node_or_null("CharacterModel")
	if model:
		skeleton = find_skeleton(model)
		if skeleton:
			print("Skeleton found! Bones: ", skeleton.get_bone_count())
			find_bone_indices()
		else:
			print("No skeleton found")

func find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node
	for child in node.get_children():
		var result = find_skeleton(child)
		if result:
			return result
	return null

func find_bone_indices():
	if not skeleton:
		return
	
	for i in range(skeleton.get_bone_count()):
		var bone_name = skeleton.get_bone_name(i).to_lower()
		print("Bone ", i, ": ", bone_name)
		
		if "spine" in bone_name or "chest" in bone_name:
			spine_bone = i
		elif "head" in bone_name:
			head_bone = i
		elif "arm" in bone_name or "shoulder" in bone_name:
			if "left" in bone_name or "l_" in bone_name:
				left_arm_bone = i
			elif "right" in bone_name or "r_" in bone_name:
				right_arm_bone = i
		elif "leg" in bone_name or "thigh" in bone_name:
			if "left" in bone_name or "l_" in bone_name:
				left_leg_bone = i
			elif "right" in bone_name or "r_" in bone_name:
				right_leg_bone = i

func _process(delta):
	if not skeleton or not player:
		return
	
	time += delta
	update_procedural_animation()

func update_procedural_animation():
	var horizontal_speed = Vector2(player.velocity.x, player.velocity.z).length()
	
	# Determine state
	if not player.is_on_floor():
		current_state = "jump"
	elif horizontal_speed > 0.1:
		if player.is_sprinting:
			current_state = "run"
		else:
			current_state = "walk"
	else:
		current_state = "idle"
	
	# Apply procedural animations
	match current_state:
		"idle":
			animate_idle()
		"walk":
			animate_walk()
		"run":
			animate_run()
		"jump":
			animate_jump()

func animate_idle():
	# Gentle breathing motion
	if spine_bone >= 0:
		var breath = sin(time * 2.0) * 0.02
		var pose = skeleton.get_bone_pose_rotation(spine_bone)
		skeleton.set_bone_pose_rotation(spine_bone, Quaternion(Vector3(breath, 0, 0)))
	
	# Slight head movement
	if head_bone >= 0:
		var head_move = sin(time * 1.5) * 0.03
		skeleton.set_bone_pose_rotation(head_bone, Quaternion(Vector3(head_move, 0, 0)))

func animate_walk():
	var walk_speed = 4.0
	var walk_time = time * walk_speed
	
	# Leg swing
	if left_leg_bone >= 0:
		var swing = sin(walk_time) * 0.5
		skeleton.set_bone_pose_rotation(left_leg_bone, Quaternion(Vector3(swing, 0, 0)))
	
	if right_leg_bone >= 0:
		var swing = sin(walk_time + PI) * 0.5
		skeleton.set_bone_pose_rotation(right_leg_bone, Quaternion(Vector3(swing, 0, 0)))
	
	# Arm swing (opposite to legs)
	if left_arm_bone >= 0:
		var swing = sin(walk_time + PI) * 0.3
		skeleton.set_bone_pose_rotation(left_arm_bone, Quaternion(Vector3(swing, 0, 0)))
	
	if right_arm_bone >= 0:
		var swing = sin(walk_time) * 0.3
		skeleton.set_bone_pose_rotation(right_arm_bone, Quaternion(Vector3(swing, 0, 0)))
	
	# Body bob
	if spine_bone >= 0:
		var bob = abs(sin(walk_time * 2.0)) * 0.05
		skeleton.set_bone_pose_rotation(spine_bone, Quaternion(Vector3(bob, 0, 0)))

func animate_run():
	var run_speed = 6.0
	var run_time = time * run_speed
	
	# Faster leg swing
	if left_leg_bone >= 0:
		var swing = sin(run_time) * 0.7
		skeleton.set_bone_pose_rotation(left_leg_bone, Quaternion(Vector3(swing, 0, 0)))
	
	if right_leg_bone >= 0:
		var swing = sin(run_time + PI) * 0.7
		skeleton.set_bone_pose_rotation(right_leg_bone, Quaternion(Vector3(swing, 0, 0)))
	
	# Faster arm swing
	if left_arm_bone >= 0:
		var swing = sin(run_time + PI) * 0.5
		skeleton.set_bone_pose_rotation(left_arm_bone, Quaternion(Vector3(swing, 0, 0)))
	
	if right_arm_bone >= 0:
		var swing = sin(run_time) * 0.5
		skeleton.set_bone_pose_rotation(right_arm_bone, Quaternion(Vector3(swing, 0, 0)))
	
	# Forward lean
	if spine_bone >= 0:
		skeleton.set_bone_pose_rotation(spine_bone, Quaternion(Vector3(0.2, 0, 0)))

func animate_jump():
	# Arms up
	if left_arm_bone >= 0:
		skeleton.set_bone_pose_rotation(left_arm_bone, Quaternion(Vector3(-0.5, 0, 0)))
	
	if right_arm_bone >= 0:
		skeleton.set_bone_pose_rotation(right_arm_bone, Quaternion(Vector3(-0.5, 0, 0)))
	
	# Legs tucked
	if left_leg_bone >= 0:
		skeleton.set_bone_pose_rotation(left_leg_bone, Quaternion(Vector3(0.3, 0, 0)))
	
	if right_leg_bone >= 0:
		skeleton.set_bone_pose_rotation(right_leg_bone, Quaternion(Vector3(0.3, 0, 0)))
