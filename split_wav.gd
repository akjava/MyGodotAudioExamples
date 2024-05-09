extends Node

var stream
var original_data
func _ready():
	var player = find_child("AudioStreamPlayer")
	stream = player.stream
	print(player.stream)
	original_data = player.stream.data
	var data_size = player.stream.data.size()
	var sample_rate = player.stream.mix_rate
	var stereo_size = 2 if player.stream.stereo else 1
	var length = player.stream.get_length()
	var byte_size = 1 if player.stream.format == AudioStreamWAV.FORMAT_8_BITS  else 2
	var samples = sample_rate * length * byte_size
	print("size = %s"%data_size)
	print("sample_rate = %s"%sample_rate)
	print("stereo = %s"%stereo_size)
	print("length = %s"%length)
	print("samples = %s"%samples)
	
	find_child("EndLineEdit").text = str(length)


func _on_trim_button_pressed():
	var start = float(find_child("StartLineEdit").text)
	var end = float(find_child("EndLineEdit").text)
	var start_index = WavSplitter.time_to_index(stream,start)
	var end_index = WavSplitter.time_to_index(stream,end)
	var splited_data = WavSplitter.split_wav_file(original_data,start_index,end_index)
	var player = find_child("AudioStreamPlayer")
	player.stream.data = splited_data
	player.play()
