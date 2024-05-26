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
	
	var audio2 = WavParser.parse_wav_file("res://files/cv02_1-10.wav")
	print("second audio size = %s"%audio2.data.size())
	var silence = WavUtils.generate_silence(1.0,player.stream.stereo,player.stream.mix_rate,player.stream.format)
	print("silence size = %s"%silence.size())
	var new_data = WavUtils.join([stream.data , silence,audio2.data])
	print("mixed all size = %s"%new_data.size())
	stream.data = new_data
	stream.save_to_wav("wav_joined.wav")

func _on_trim_button_pressed():
	var start = float(find_child("StartLineEdit").text)
	var end = float(find_child("EndLineEdit").text)
	var start_index = WavSplitter.time_to_index(stream,start)
	var end_index = WavSplitter.time_to_index(stream,end)
	var splited_data = WavSplitter.split_wav_file(original_data,start_index,end_index)
	var player = find_child("AudioStreamPlayer")
	player.stream.data = splited_data
	player.play()


func _on_button_pressed():
	find_child("AudioStreamPlayer").play()
