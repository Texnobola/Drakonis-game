extends AudioStreamPlayer3D

func _ready():
	var sample_rate = 22050
	var duration = 0.12
	var samples = int(sample_rate * duration)
	var data = PackedVector2Array()
	
	# Generate more realistic footstep with multiple frequency layers
	for i in range(samples):
		var t = float(i) / float(sample_rate)
		var envelope = exp(-t * 15.0)  # Sharp attack, quick decay
		var value = 0.0
		
		# Low thump (bass)
		value += sin(t * 80.0 * TAU) * envelope * 0.4
		value += sin(t * 120.0 * TAU) * envelope * 0.3
		
		# Mid crunch
		value += sin(t * 250.0 * TAU) * envelope * 0.15
		
		# High texture (dirt/gravel sound)
		value += (randf() - 0.5) * envelope * 0.25
		
		data.append(Vector2(value, value))
	
	var audio_stream = AudioStreamWAV.new()
	audio_stream.format = AudioStreamWAV.FORMAT_16_BITS
	audio_stream.mix_rate = sample_rate
	audio_stream.stereo = true
	
	var byte_array = PackedByteArray()
	for sample in data:
		var left = int(clamp(sample.x * 32767, -32768, 32767))
		var right = int(clamp(sample.y * 32767, -32768, 32767))
		byte_array.append_array(PackedByteArray([left & 0xFF, (left >> 8) & 0xFF]))
		byte_array.append_array(PackedByteArray([right & 0xFF, (right >> 8) & 0xFF]))
	
	audio_stream.data = byte_array
	stream = audio_stream
	volume_db = 4.0
	max_distance = 50.0

func play_footstep():
	pitch_scale = randf_range(0.85, 1.15)
	play()
