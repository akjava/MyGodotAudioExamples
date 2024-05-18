# https://github.com/akjava/MyGodotAudioExamples (public)
class_name AudioUtils

const EFFECT_SPECTRAM_ANALYZER =  "AudioEffectSpectrumAnalyzer"

static func check_bus_effect(bus_index: int, effect_slot: int, effect_class_name: String):
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
			push_error("%s is exist in Bus %s slot %s,but disabled" % [effect_class_name,bus_index,effect_slot])
		
		return effect_enabled
