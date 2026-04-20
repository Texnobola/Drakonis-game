extends AudioStreamPlayer3D

func _ready():
	# Create a simple footstep sound using AudioStreamWAV
	var sample_rate = 22050
	var duration = 0.15
	var samples = int(sample_rate * duration)
	var data = PackedVector2Array()
	
	# Generate a louder thump sound with more bass
	for i in range(samples):
		var t = float(i) / float(sample_rate)
		var frequency = 80.0
		var envelope = 1.0 - (float(i) / float(samples))
		# Much louder - increased from 0.5 to 0.95
		var value = sin(t * frequency * TAU) * envelope * 0.95
		# Add some noise for more realistic sound
		value += (randf() - 0.5) * 0.3 * envelope
		data.append(Vector2(value, value))
	
	var audio_stream = AudioStreamWAV.new()
	audio_stream.format = AudioStreamWAV.FORMAT_16_BITS
	audio_stream.mix_rate = sample_rate
	audio_stream.stereo = true
	
	# Convert Vector2Array to byte array
	var byte_array = PackedByteArray()
	for sample in data:
		var left = int(clamp(sample.x * 32767, -32768, 32767))
		var right = int(clamp(sample.y * 32767, -32768, 32767))
		byte_array.append_array(PackedByteArray([left & 0xFF, (left >> 8) & 0xFF]))
		byte_array.append_array(PackedByteArray([right & 0xFF, (right >> 8) & 0xFF]))
	
	audio_stream.data = byte_array
	stream = audio_stream
	volume_db = 3.0  # Balanced volume
	max_distance = 50.0
	unit_size = 1.0

func play_footstep():
	pitch_scale = randf_range(0.85, 1.15)
	play()
