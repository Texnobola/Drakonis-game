extends AudioStreamPlayer

func _ready():
	var sample_rate = 22050
	var duration = 8.0  # 8 second loop
	var samples = int(sample_rate * duration)
	var data = PackedVector2Array()
	
	# Generate ambient atmospheric music
	for i in range(samples):
		var t = float(i) / float(sample_rate)
		var value = 0.0
		
		# Base drone (low frequency)
		value += sin(t * 110.0 * TAU) * 0.15
		value += sin(t * 165.0 * TAU) * 0.12
		
		# Harmonic layers
		value += sin(t * 220.0 * TAU) * 0.08
		value += sin(t * 330.0 * TAU) * 0.06
		
		# Slow modulation for movement
		var mod = sin(t * 0.5 * TAU) * 0.3 + 0.7
		value *= mod
		
		data.append(Vector2(value, value))
	
	var audio_stream = AudioStreamWAV.new()
	audio_stream.format = AudioStreamWAV.FORMAT_16_BITS
	audio_stream.mix_rate = sample_rate
	audio_stream.stereo = true
	audio_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	audio_stream.loop_begin = 0
	audio_stream.loop_end = samples
	
	var byte_array = PackedByteArray()
	for sample in data:
		var left = int(clamp(sample.x * 32767, -32768, 32767))
		var right = int(clamp(sample.y * 32767, -32768, 32767))
		byte_array.append_array(PackedByteArray([left & 0xFF, (left >> 8) & 0xFF]))
		byte_array.append_array(PackedByteArray([right & 0xFF, (right >> 8) & 0xFF]))
	
	audio_stream.data = byte_array
	stream = audio_stream
	volume_db = -10.0  # Quiet background music
	autoplay = true
