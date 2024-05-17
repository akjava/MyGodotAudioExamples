# https://github.com/akjava/MyGodotAudioExamples
class_name SppectrumToEnergy extends Control

var _spectrum
var MIN_DB = 60 # var energy = clamp((MIN_DB + linear_to_db(volume)) / MIN_DB, 0, 1)

var _last_energy = 0
var _bus_index
var _effect_index
var _min_hz = 0
var _max_hz = 10000
signal sectrum_energy_changed(energy)
var enable_monitor = true
var min_time = 0.05
var _total = 0
func _init(bus = 0,effect = 0):
	_bus_index = bus
	_effect_index = effect
	
func _ready():
	_spectrum = AudioServer.get_bus_effect_instance(_bus_index, _effect_index)
	
	
func _process(delta):
	
	if not enable_monitor:
		return
	
	_total += delta
	if _total < min_time:
		return
	_total = 0
	#print(delta)
	var energy = _calc_energy()
	if energy != _last_energy:
		emit_signal("sectrum_energy_changed",energy)
		_last_energy = energy
	
		
		
func _calc_energy():
	if _spectrum:
		# converted 0 - 1 energy
		var volume  = _spectrum.get_magnitude_for_frequency_range(_min_hz, _max_hz).length()
		var energy = clamp((MIN_DB + linear_to_db(volume)) / MIN_DB, 0, 1)
		return energy
	else:
		return 0



