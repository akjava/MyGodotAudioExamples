extends Control
const MIN_DB = 60
var spectrum
var started = false
var time
var drop_frame_count

var mag_dics =[]

var hz_step = 5

	
func _ready():
	AudioUtils.check_bus_effect(0,0,AudioUtils.EFFECT_SPECTRAM_ANALYZER)
	spectrum = AudioServer.get_bus_effect_instance(0,0)
	#spectrum.fft_size = AudioEffectSpectrumAnalyzer.FFT_SIZE_MAX
	if spectrum == null:
		print("warning add spectrum on Audio TAB")
	var rate = AudioServer.get_mix_rate() #default are 48000
	print(str("Audio-server mix-rate = ", rate))#I don't know can this value  change or not.however must be 48000
	
	if(rate != 48000):
		print("invalid mix-rate")		
		
	hz_step_changed()
	
		

var spectram_ranges = [
#Vector2i(0,10000),
#Vector2i(165,2550),
#Vector2i(165,220),
#Vector2i(220,246),
#Vector2i(246,293),
#Vector2i(246,2550)

# manual
#Vector2i(0,250),
#Vector2i(250,500),
#Vector2i(500,750),
#Vector2i(750,1000),
#Vector2i(1000,1250),
#Vector2i(1250,1500),
#Vector2i(1500,1750),
#Vector2i(1500,2000),
#Vector2i(2000,2500),

#Vector2i(0,500),
#Vector2i(500,1000),
#Vector2i(1000,2000),# O
#Vector2i(2000,4000),# I or E
#Vector2i(1500,2000),# U,not I

]

func _process(delta):
	#print(_delta)
	
	if started:
		if delta > 0.017:
			drop_frame_count += 1
			print("dropped %s"%[delta])
		time += delta
		
		#var mag: float = spectrum.get_magnitude_for_frequency_range(0, 10000,1).length()
		for i in spectram_ranges.size():
			var sp_range = spectram_ranges[i]
			var type = 0 if i != 0 else 1
			type = 0
			var mag: float = spectrum.get_magnitude_for_frequency_range(sp_range.x, sp_range.y,type).length()
			mag_dics[i][time] = mag
		

	
func _draw():
	pass
	
func _on_Start_pressed():
	started = true
	
	time = 0.0
	drop_frame_count = 0
	find_child("Player").play()
	
func _on_Stop_pressed():
	started = false
	find_child("Player").stop()

func _on_player_finished():
	print("finished")
	started = false
	
	
	var audio_length = find_child("Player").stream.get_length() 
	var possible_size = audio_length/(1.0/60)
	print("audio-length = %s frames = %s(possible %s) dropped = %s"%[audio_length,mag_dics[0].keys().size(),possible_size,drop_frame_count])
	
	#print(mag_dic)
	var control = find_child("Control")
	control.hz_step = hz_step
	control.data_dics = mag_dics
	control.queue_redraw()


func _on_hz_option_button_item_selected(index):
	var value =find_child("HzOptionButton").get_item_text(index)
	hz_step = int(value)
	hz_step_changed()

func hz_step_changed():
	spectram_ranges.clear()
	mag_dics.clear()
	for i in range(200):
		spectram_ranges.append(Vector2i(i*hz_step,(i+1)*hz_step))
	# init dic
	for i in spectram_ranges.size():
		mag_dics.append({})


func _on_button_pressed():
	var control = find_child("Control")
	var img = control.get_viewport().get_texture().get_image()
	img.save_jpg("tmp.jpg")
