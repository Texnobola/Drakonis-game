extends Node

var current_checkpoint_position: Vector3 = Vector3(0, 3, 0)
var current_checkpoint_id: int = -1

func set_checkpoint(position: Vector3, id: int):
	current_checkpoint_position = position
	current_checkpoint_id = id
	print("Checkpoint activated at: ", position)

func get_checkpoint_position() -> Vector3:
	return current_checkpoint_position

func respawn_player(player: CharacterBody3D):
	if player:
		player.global_position = current_checkpoint_position
		player.velocity = Vector3.ZERO
		print("Player respawned at checkpoint")
