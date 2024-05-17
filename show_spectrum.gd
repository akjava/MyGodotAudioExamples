extends Node2D


const VU_COUNT = 512
const FREQ_MAX = 11050.0

const WIDTH = 1600
const HEIGHT = 1

const MIN_DB = 60

var spectrum

var h_index = 0

var datas = []

var started = false
var silero_script = load("res://onnx_silero/SlieroVadOnnxModel.cs")

var model = null;
var player
var capture
var total_captures = 0
var speaking = false
var audio_chunk_index = 0
func _ready():
	spectrum = AudioServer.get_bus_effect_instance(0,0)
	if spectrum == null:
		print("warning add spectrum on Audio TAB")
	var rate = AudioServer.get_mix_rate() #default are 48000
	print(str("Audio-server mix-rate = ", rate))#I don't know can this value  change or not.however must be 48000

	if(rate != 48000):
		print("invalid mix-rate")		
	
	AudioServer.add_bus()
	var bus_id = AudioServer.get_bus_count() - 1 # last one is new one.
	print(str("bus name = ", AudioServer.get_bus_name(bus_id)))

	capture = AudioEffectCapture.new()
	AudioServer.add_bus_effect(bus_id, capture)
	
	player = find_child("Player")
	player.bus = AudioServer.get_bus_name(bus_id)
	
	
	var path = ProjectSettings.globalize_path("res://files/silero_vad.onnx")
	
	model = silero_script.new(path);#call  public SlieroVadOnnxModel(string modelPath) in cs
	

var result = 0
func _process(_delta):
	
	find_child("Fps").set_text("FPS " + str(Engine.get_frames_per_second()))
	#part of spectram
	if started:
		if not find_child("Player").playing:
			print("stopped")
			started = false
			#way to know end play
			return
		calc()
	if not player.playing:
		return
	# capture
	var chunk = 512
	var min_chunk = chunk * 3 # convert 48000 to 16000
	var availables = capture.get_frames_available()
	if availables >= min_chunk:
		total_captures += min_chunk
		# print("av = ", availables)
		# print("total = ", total_captures)
		
		var buffer = capture.get_buffer(min_chunk)
		var input = Array()
		var short_max = 1#32767 #1
		for i in range(chunk):
			var array = []
			#array.append(buffer[i * 3].x) 
			#array.append(buffer[i * 3].y) 
			array.append((buffer[i * 3].x + buffer[i * 3].y) * (short_max / 2.0))
			#array.append((buffer[i * 3+1].x + buffer[i * 3+1].y) * (short_max / 2.0))
			#array.append((buffer[i * 3+2].x + buffer[i * 3+2].y) * (short_max / 2.0))
			input.append(array.max())
			if array.max()<0:
				pass
				#print("minus")
		#no idea to send [input]
		result = model.Call(input, 16000)[0]  # replace "method_name" with your function name
		if result < 0.5 and speaking:
			#print("No Audio time = %s, pb =%s" % [audio_chunk_index * 0.032, result])
			speaking = false
		elif result >= 0.5 and not speaking:
			#print("Yes Audio time = %s, pb =%s" % [audio_chunk_index * 0.032, result])
			speaking = true
		
		# print("buffer = ", buffer.size())

		audio_chunk_index += 1
		buffer = null
	else:
		if total_captures > 0:
			var sec = total_captures / 48000
			#print("total-sec", sec)
	
	find_child("Control").predicts.append(result)
	#print(availables)
	
	

	
func _physics_process(_delta):
	pass
	#update()
	
func calc():
	#warning-ignore:integer_division
	var w = WIDTH / VU_COUNT
	var prev_hz = 0
	
	var mag: float = spectrum.get_magnitude_for_frequency_range(0, 10000,1).length()
	find_child("Control").magnitudes.append(mag)
	
	find_child("Control").queue_redraw()
	
	var heights =[]
	for i in range(1, VU_COUNT+1):
		
		var hz = i * FREQ_MAX / VU_COUNT;
		var magnitude: float = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy = clamp((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		#var height = energy * HEIGHT
		heights.append(energy * 2)
		#draw_rect(Rect2(w * i,h_index * HEIGHT + HEIGHT - height, w, height), Color.white)
		prev_hz = hz
	datas.append(heights)

func _draw():
	#draw_rect(Rect2(0,0, WIDTH, 2000), Color.black)
	var w = WIDTH / VU_COUNT
	for j in range(datas.size()):
		h_index = j
		var data = datas[j]
		for i in range(data.size()):
			var energy = data[i]
			var height = energy * HEIGHT
			draw_rect(Rect2(w * i,h_index * HEIGHT + HEIGHT - height, w, height), Color(energy,energy,energy))
	
	

func _on_Start_pressed():
	started = true
	find_child("Player").play()


func _on_Stop_pressed():
	started = false
	find_child("Player").stop()
	#update()
	


	


func _on_player_finished():
	print("finished")
	find_child("Control").create_separations()
	find_child("Control").queue_redraw()
