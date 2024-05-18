# MyGodotAudioExamples
a small godot audio examples.Be careful to use there are better official way.I prefer writing code than search it.
## LICENSE
MIT
## Audio Effect Capture to wav
The audio can be saved from before you press the button, up to the duration set in the buffer length. You can convert the recorded audio to WAV format for text-to-speech or automatic speech recognition purposes, but please note that this requires significant CPU resources.

## Class Info
Automatic created from mermaid-data
### AudioUtils
#### check_bus_effect(bus_index: int, effect_slot: int, effect_class_name: String)


**Name:** `check_bus_effect`

**Parameters:**
* `bus_index`: Index of the bus.
* `effect_slot`: Slot index of the effect.
* `effect_class_name`: Name of the effect class to check.

**Returns:**
* `True`: If the effect is enabled.
* `False`: If the effect is not enabled.

**Description:**
This method checks if a specific effect is enabled at a given bus and slot index. It performs the following steps:

1. **Check if the effect class exists at the bus and slot index:**
   - If the effect class doesn't exist, the effect is not enabled.

2. **Count the number of effects at the bus index:**
   - If the count is less than or equal to the `effect_slot`, the effect is not enabled.

3. **Get the bus effect:**
   - If the effect is null, it is not enabled.

4. **Check if the bus effect name matches the provided `effect_class_name`:**
   - If the names don't match, the effect is not enabled.

5. **Check if the bus effect is enabled:**
   - If the effect is not enabled, the method returns `False`.

**Flowchart:**
The flowchart illustrates the steps involved in the `check_bus_effect` method. It shows the decision points and possible outcomes based on the conditions checked. The method returns `True` only if all conditions are met, indicating that the effect is enabled.

![layout_manager](https://github.com/akjava/MyGodotAudioExamples/assets/1138124/09cf3259-f188-4266-97cc-0f1db798d2aa)
