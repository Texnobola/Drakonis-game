extends Node

@onready var spring_arm: SpringArm3D = get_parent().get_node("CameraPivot/SpringArm3D")
@onready var camera: Camera3D = get_parent().get_node("CameraPivot/SpringArm3D/Camera3D")
@onready var character_model = get_parent().get_node_or_null("CharacterModel")

enum CameraMode { FIRST_PERSON, SECOND_PERSON, THIRD_PERSON }
var current_mode = CameraMode.THIRD_PERSON

# Camera distances
const FIRST_PERSON_DISTANCE = 0.0
const SECOND_PERSON_DISTANCE = 2.5
const THIRD_PERSON_DISTANCE = 5.0

func _ready():
	set_camera_mode(current_mode)
	print("Camera View Switcher Ready - Press P to switch views")

func _input(event):
	if event.is_action_pressed("switch_camera"):
		cycle_camera_mode()

func cycle_camera_mode():
	match current_mode:
		CameraMode.FIRST_PERSON:
			current_mode = CameraMode.SECOND_PERSON
			print("Camera: 2nd Person")
		CameraMode.SECOND_PERSON:
			current_mode = CameraMode.THIRD_PERSON
			print("Camera: 3rd Person")
		CameraMode.THIRD_PERSON:
			current_mode = CameraMode.FIRST_PERSON
			print("Camera: 1st Person")
	
	set_camera_mode(current_mode)

func set_camera_mode(mode: CameraMode):
	match mode:
		CameraMode.FIRST_PERSON:
			spring_arm.spring_length = FIRST_PERSON_DISTANCE
			if character_model:
				character_model.visible = true
		CameraMode.SECOND_PERSON:
			spring_arm.spring_length = SECOND_PERSON_DISTANCE
			if character_model:
				character_model.visible = true
		CameraMode.THIRD_PERSON:
			spring_arm.spring_length = THIRD_PERSON_DISTANCE
			if character_model:
				character_model.visible = true
