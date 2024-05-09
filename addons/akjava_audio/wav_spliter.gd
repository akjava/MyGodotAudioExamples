class_name WavSplitter extends Node



# This function attempts to parse a WAV file and print its basic details.

#const is_debug = false

static func time_to_index(stream:AudioStreamWAV,time_sec:float) -> int:
	var sample_rate = stream.mix_rate
	var stereo_size = 2 if stream.stereo else 1
	
	var byte_size = 1 if stream.format == AudioStreamWAV.FORMAT_8_BITS  else 2
	var samples = sample_rate * time_sec * byte_size
	return samples
	
static func split_wav_file(input_data:PackedByteArray,start_index:int,end_index:int) -> PackedByteArray:
	assert(start_index<end_index)
	return input_data.slice(start_index,end_index)
	
	 
