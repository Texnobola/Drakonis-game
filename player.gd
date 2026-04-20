extends CharacterBody3D

const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const CROUCH_SPEED = 2.5
const JUMP_VELOCITY = 4.5
const DOUBLE_JUMP_VELOCITY = 4.0
const AIR_DASH_SPEED = 40.0
const MOUSE_SENSITIVITY = 0.003
const CROUCH_DEPTH = 0.5
const CROUCH_SPEED_TRANSITION = 10.0
const FOV_CHANGE = 5.0

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/SpringArm3D/Camera3D
@onready var crosshair = get_node("/root/Main/UI/Crosshair")
@onready var collision_shape = $CollisionShape3D
@onready var mesh_instance = $MeshInstance3D
@onready var footstep_timer = $FootstepTimer
@onready var audio_player = $AudioStreamPlayer3D
@onready var dash_particles = $DashParticles

var camera_rotation_x = 0.0
var current_speed = WALK_SPEED
var is_crouching = false
var has_double_jumped = false
var has_air_dashed = false
var default_fov = 75.0
var target_fov = 75.0
var standing_height = 2.0
var crouching_height = 1.0
var current_height = 2.0
var last_position = Vector3.ZERO
var footstep_distance = 0.0
var footstep_threshold = 2.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if crosshair:
		crosshair.visible = true
	default_fov = camera.fov
	last_position = global_position
	
	if collision_shape and collision_shape.shape:
		standing_height = collision_shape.shape.height
		crouching_height = standing_height * 0.5
		current_height = standing_height
	
	var death_zone = get_node_or_null("/root/Main/Level/DeathZone")
	if death_zone:
		death_zone.body_entered.connect(_on_death_zone_entered)

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera_rotation_x -= event.relative.y * MOUSE_SENSITIVITY
		camera_rotation_x = clamp(camera_rotation_x, -1.5, 1.2)
		camera_pivot.rotation.x = camera_rotation_x
	
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			if crosshair:
				crosshair.visible = false
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			if crosshair:
				crosshair.visible = true

func _physics_process(delta: float) -> void:
	handle_crouch(delta)
	handle_movement(delta)
	handle_air_dash()
	handle_fov(delta)
	handle_footsteps()
	move_and_slide()

func handle_crouch(delta: float):
	var target_height = standing_height
	var was_crouching = is_crouching
	
	if Input.is_action_pressed("crouch"):
		is_crouching = true
		target_height = crouching_height
	else:
		if is_crouching and not check_ceiling():
			is_crouching = false
		if is_crouching:
			target_height = crouching_height
	
	current_height = lerp(current_height, target_height, delta * CROUCH_SPEED_TRANSITION)
	
	if collision_shape and collision_shape.shape:
		collision_shape.shape.height = current_height
		collision_shape.position.y = current_height / 2.0
	
	if mesh_instance:
		mesh_instance.scale.y = current_height / standing_height
		mesh_instance.position.y = 0

func check_ceiling() -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, global_position + Vector3.UP * standing_height)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	return result.size() > 0

func handle_movement(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		has_double_jumped = false
		has_air_dashed = false
	
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif not has_double_jumped:
			velocity.y = DOUBLE_JUMP_VELOCITY
			has_double_jumped = true
	
	if is_crouching:
		current_speed = CROUCH_SPEED
		target_fov = default_fov - 5.0
	elif Input.is_action_pressed("sprint") and not is_crouching:
		current_speed = SPRINT_SPEED
		target_fov = default_fov + FOV_CHANGE
	else:
		current_speed = WALK_SPEED
		target_fov = default_fov
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

func handle_air_dash():
	if Input.is_action_just_pressed("air_dash") and not is_on_floor() and not has_air_dashed:
		air_dash()

func air_dash():
	has_air_dashed = true
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dash_direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if dash_direction == Vector3.ZERO:
		dash_direction = -transform.basis.z
	
	velocity.x = dash_direction.x * AIR_DASH_SPEED
	velocity.z = dash_direction.z * AIR_DASH_SPEED
	velocity.y = 0
	
	# Visual effects - spawn particles behind the player
	if dash_particles:
		# Position particles at player center
		dash_particles.global_position = global_position
		# Rotate to emit backwards from dash direction
		var look_at_pos = global_position + dash_direction
		dash_particles.look_at(look_at_pos, Vector3.UP)
		dash_particles.restart()
		dash_particles.emitting = true

func handle_fov(delta: float):
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

func handle_footsteps():
	if not is_on_floor():
		return
	
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z).length()
	if horizontal_velocity < 0.1:
		return
	
	var distance_moved = global_position.distance_to(last_position)
	footstep_distance += distance_moved
	last_position = global_position
	
	var step_threshold = footstep_threshold
	if Input.is_action_pressed("sprint"):
		step_threshold = footstep_threshold * 0.7
	elif is_crouching:
		step_threshold = footstep_threshold * 1.5
	
	if footstep_distance >= step_threshold:
		play_footstep()
		footstep_distance = 0.0

func play_footstep():
	if audio_player:
		audio_player.play_footstep()

func _on_death_zone_entered(body):
	if body == self:
		CheckpointManager.respawn_player(self)
