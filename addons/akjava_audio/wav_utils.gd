# https://github.com/akjava/MyGodotAudioExamples (public)

class_name WavUtils

#
# silence means just 0 array
# var duration = 1.0
# var silence = generate_silence.generate_silence(duration,player.stream.stereo,player.stream.mix_rate,player.stream.format)
# player.stream.data += silence
static func generate_silence(duration_sec:float,is_stereo:bool,mix_rate:int,format = AudioStreamWAV.FORMAT_16_BITS)->PackedByteArray:
	var stereo_size = 2 if is_stereo else 1
	var byte_size = 1 if format == AudioStreamWAV.FORMAT_8_BITS  else 2
	
	var size = int(mix_rate * duration_sec) * stereo_size * byte_size
	var array = PackedByteArray()
	array.resize(size)
	return array
	
#WavStream.data
static func join(array:Array[PackedByteArray])->PackedByteArray:
	var zero = PackedByteArray()
	return array.reduce(func(initial,bytes):return initial+bytes,zero)
	
# for some long silence need?
static func calc_frame_duration(frame_per_second:float,frames:int)->float:
	var per_second = 1.0 / frame_per_second
	return per_second * frames
	
# for calc how many frame need for audio_duration
static func calc_frame_count(frame_per_second:float,duration:float) ->int:
	var per_second = 1.0 / frame_per_second
	return ceil(duration/per_second)
	
