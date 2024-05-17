extends Node

var recording
var audio_capture
var is_recording = false
var wav 
var wav_bytes := PackedByteArray()

# some code are copy from 

#at least you need understand how to handle mic.https://docs.godotengine.org/en/stable/tutorials/audio/recording_with_microphone.html
#The audio before pressing the button can also be saved. (for the time specified in buffer length).

#if no mic detected E 0:00:00:0705   audio_device_init: Condition "hr != ((HRESULT)0x00000000)" is true. Returning: ERR_CANT_OPEN
#input_start: WASAPI: init_input_device error


func _ready():
	var record_bus_index = AudioServer.get_bus_index("Record") #Record bus must be exist in default_bus_layout.tres(add Record and Capture Effect)
	assert(record_bus_index != -1, "Bus '%s' not found.add manually and rename it from below Audio-Tab" % "Record")
	check_bus_effect(record_bus_index,0,"AudioEffectCapture")
			
	audio_capture = AudioServer.get_bus_effect(record_bus_index, 0)
	AudioServer.set_bus_mute(record_bus_index,true)#avoid Mic-Echo
	
	wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.stereo = true
	
	wav.mix_rate = AudioServer.get_mix_rate()
	print("mix-rate:%s"%wav.mix_rate)
	
	
func check_bus_effect(bus_index: int, effect_slot: int, effect_class_name: String):
	var count = AudioServer.get_bus_effect_count (bus_index)
	if count <= effect_slot:
		push_error("Bus Effect empty or smaller than index effect-size =%s effect_slot = %s.Add effect manually from below audio-tab"%[count,effect_slot])
		return
	var effect = AudioServer.get_bus_effect(bus_index, effect_slot)
	if effect == null:
		push_error("%s not exist in Bus %s slot %s"%[effect_class_name,bus_index,effect_slot])
		return false
	elif  effect.get_class() != effect_class_name:
		push_error("Effect is not %s in Bus %s slot %s.there are %s" % [effect_class_name,bus_index,effect_slot,effect.get_class()])
		return false
	else:
		var effect_enabled = AudioServer.is_bus_effect_enabled(bus_index, effect_slot)
		if effect_enabled:
			pass
		else:
			print("%s is exist in Bus %s slot %s,but disabled" % [effect_class_name,bus_index,effect_slot])
		
		return effect_enabled

	

func _process(_delta):	
	_capture_recording_audio()	
	
func _capture_recording_audio():
	#cI an't set buffer length from script.that is initialized inner.set value from editor's inspector.see audio_effect_capture.cpp
	if audio_capture!= null and is_recording:
		var available = audio_capture.get_frames_available()
		if available >0:
			var array = audio_capture.get_buffer (available)
			
			wav_bytes.append_array(convert_vector2_array_to_byte_array(array))
			
				
		
		
		

func _on_record_button_pressed():
	if is_recording:
		
		find_child("PlayButton").disabled = false
		find_child("SaveButton").disabled = false
		#$SaveButton.disabled = false
		
		find_child("RecordButton").text = "Record"
		find_child("Status").text = "Monitoring.."
		is_recording = false
		wav.set_data(wav_bytes)
	else:
		find_child("PlayButton").disabled = true
		find_child("SaveButton").disabled = true
		#$SaveButton.disabled = true
		
		find_child("RecordButton").text = "Stop"
		find_child("Status").text = "Recording..."
		is_recording = true
		wav_bytes.clear()
		print("wav clear")
		
		
#If your audio is empty check Project settings audio/drive/enable_input
func _on_play_button_pressed():
	
	print(wav.get_data().size())
	find_child("AudioStreamPlayer").stream = wav
	find_child("AudioStreamPlayer").play()


func convert_vector2_array_to_byte_array(vector2_array: PackedVector2Array) -> PackedByteArray:
	var byte_array := PackedByteArray()
	
	for i in range(vector2_array.size()):
		# 
		var left_channel_sample := vector2_array[i].x
		var right_channel_sample := vector2_array[i].y
		
		# convert from -1.0 - 1.0 to -32768 - 32767(16bit)
		var left_sample_int = int(clamp(left_channel_sample * 32767, -32768, 32767))
		var right_sample_int = int(clamp(right_channel_sample * 32767, -32768, 32767))
		
		# append bytes little-endian
		byte_array.append_array(int16_to_byte_array(left_sample_int))
		byte_array.append_array(int16_to_byte_array(right_sample_int))
	return byte_array

func int16_to_byte_array(sample:int) -> PackedByteArray:
	var bytes := PackedByteArray()
	bytes.append(sample & 0xFF)  
	bytes.append((sample >> 8) & 0xFF) 
	return bytes

func _on_save_button_pressed():
	var error = wav.save_to_wav("res://capture.wav")
	if error == OK:
		find_child("Status").text = "Saved"
	else:
		find_child("Status").text = "Faild to wave save error-code = %s"%error
