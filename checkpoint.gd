extends Area3D

@export var checkpoint_id: int = 0
@onready var mesh = $MeshInstance3D
@onready var particles = $GPUParticles3D

var is_activated = false

func _ready():
	body_entered.connect(_on_body_entered)
	if mesh and mesh.get_surface_override_material(0):
		mesh.get_surface_override_material(0).albedo_color = Color(0.5, 0.5, 0.5)

func _on_body_entered(body):
	if body.is_in_group("player") and not is_activated:
		activate()
		CheckpointManager.set_checkpoint(global_position, checkpoint_id)

func activate():
	is_activated = true
	if mesh:
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0.2, 1.0, 0.3)
		material.emission_enabled = true
		material.emission = Color(0.2, 1.0, 0.3)
		material.emission_energy_multiplier = 2.0
		mesh.set_surface_override_material(0, material)
	
	if particles:
		particles.emitting = true
