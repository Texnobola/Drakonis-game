extends AudioStreamPlayer3D

func _ready():
	var sample_rate = 22050
	var duration = 0.4
	var samples = int(sample_rate * duration)
	var data = PackedVector2Array()
	
	# Generate smooth whoosh/wind sound
	for i in range(samples):
		var t = float(i) / float(sample_rate)
		var progress = float(i) / float(samples)
		
		# Smooth envelope (fade in and out)
		var envelope = sin(progress * PI) * 0.9
		
		# Layered wind noise
		var value = 0.0
		
		# Low rumble
		value += sin(t * 150.0 * TAU) * envelope * 0.2
		value += sin(t * 200.0 * TAU + sin(t * 8.0) * 2.0) * envelope * 0.15
		
		# Mid whoosh
		value += sin(t * 400.0 * TAU + sin(t * 12.0) * 3.0) * envelope * 0.2
		
		# High air texture
		var noise = (randf() - 0.5) * 2.0
		# Filter the noise for smoother sound
		value += noise * envelope * 0.35
		
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
	volume_db = 6.0
	max_distance = 50.0

func play_dash():
	pitch_scale = randf_range(0.9, 1.1)
	play()
