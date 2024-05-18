# https://github.com/akjava/MyGodotAudioExamples (public)

class_name WavParser extends Object

# This function attempts to parse a WAV file and print its basic details.

const is_debug = false
static func parse_wav_file(path: String) -> AudioStreamWAV:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Failed to open file")
		return

	# Check the RIFF header
	var chunk_id := f.get_buffer(4).get_string_from_utf8()
	if chunk_id != "RIFF":
		push_error("This is not a valid RIFF file.")
		f.close()
		return

	# Skip file size
	f.seek(f.get_position() + 4)
  
	# Check the WAVE format
	var format := f.get_buffer(4).get_string_from_utf8()
	if format != "WAVE":
		push_error("This is not a valid WAVE file.")
		f.close()
		return

	# fmt chunk
	var subchunk1_id := ""
	var subchunk1_size := 0
	var audio_format := 0
	var num_channels := 0
	var sample_rate := 0
	var byte_rate := 0
	var block_align := 0
	var bits_per_sample := 0

	# Continue to read until the "fmt " chunk is found
	while subchunk1_id != "fmt ":
		subchunk1_id = f.get_buffer(4).get_string_from_utf8()
		subchunk1_size = f.get_32()
		if subchunk1_id != "fmt ":
			f.seek(f.tell() + subchunk1_size)

	# Read "fmt " subchunk
	audio_format = f.get_16()
	num_channels = f.get_16()
	sample_rate = f.get_32()
	byte_rate = f.get_32()
	block_align = f.get_16()
	bits_per_sample = f.get_16()

	# Read "data" subchunk after "fmt " chunk
	var subchunk2_id := ""
	var subchunk2_size := 0

	while subchunk2_id != "data":
		subchunk2_id = f.get_buffer(4).get_string_from_utf8()
		subchunk2_size = f.get_32()
		if subchunk2_id != "data":
			f.seek(f.tell() + subchunk2_size)

	if is_debug:
		print("Audio Format: %s" % audio_format)
		print("Number of channels: %s" % num_channels)
		print("Sample rate: %s" % sample_rate)
		print("Byte rate: %s" % byte_rate)
		print("Block align: %s" % block_align)
		print("Bits per sample: %s" % bits_per_sample)
		print("Subchunk2 (Data) size: %s" % subchunk2_size)

	# At this point, `f.tell()` is the start of the audio data.
	# You can read the audio data using the `f.get_buffer(subchunk2_size)`.

	# Now, assuming you're at the start of the "data" chunk and subchunk2_size is the size of the data chunk:
	var data_chunk_size := subchunk2_size
	
	var data = f.get_buffer(data_chunk_size)

	# Assign the audio data to the stream
	var audio_stream_wav = AudioStreamWAV.new()
	audio_stream_wav.format=audio_format
	audio_stream_wav.stereo = (num_channels == 2)
	audio_stream_wav.mix_rate = sample_rate
	audio_stream_wav.data = data
	f.close()
	return audio_stream_wav
